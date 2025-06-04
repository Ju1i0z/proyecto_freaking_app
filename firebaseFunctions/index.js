// Importaciones de las funcionalidades necesarias de Firebase Functions para las funciones HTTP
const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Importaciones Firebase Admin SDK y la configuración de Stripe
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe = require("stripe")(functions.config().stripe.secret);

// Inicialización de la aplicación Firebase Admin
admin.initializeApp();

/**
 * Creación de un nuevo cliente en Stripe y registro en Firestore si no existe.
 *
 * Ruta: POST https://<proyecto>.cloudfunctions.net/createStripeCustomer
 *
 * Flujo:
 *  1. Recibe { email, name } en el body.
 *  2. Busca en Stripe si ya existe un Customer con ese email.
 *     - Si existe, devuelve { id: <customerIdExistente> }.
 *  3. Si no existe, crea un Customer en Stripe con email y name.
 *  4. Retorna { id: <nuevoCustomerId> }.
 *  5. Si ocurre un error, responde 500 { error: "Error al crear el cliente en Stripe" }.
 */
exports.createStripeCustomer = functions
  .region("europe-west3")
  .https.onRequest(async (req, res) => {
    const start = Date.now(); // Marca de tiempo para medir duración

    try {
      console.log("Iniciando creación de cliente de Stripe...");
      const { email, name } = req.body;

      // Verificación de si ya existe un cliente con ese correo
      const existingCustomers = await stripe.customers.list({
        email: email,
        limit: 1,
      });

      if (existingCustomers.data.length > 0) {
        // Si el cliente ya existe, devuelvo el ID del cliente existente
        console.log(`Cliente ya existe con el correo ${email}`);
        return res.status(200).send({ id: existingCustomers.data[0].id });
      }

      // Creación del cliente en Stripe si no existe
      const customer = await stripe.customers.create({
        email: email,
        name: name,
      });

      const end = Date.now();
      console.log(`Cliente de Stripe creado en ${(end - start)} ms`);

      res.status(200).send({ id: customer.id });
    } catch (error) {
      const end = Date.now();
      console.error(`Error creando cliente de Stripe tras ${(end - start)} ms:`, error);
      res.status(500).send({ error: "Error al crear el cliente en Stripe" });
    }
  });

/**
 * Verificación de si un usuario existe en Firestore.
 *
 * Ruta: POST https://<proyecto>.cloudfunctions.net/checkIfUserExists
 *
 * Flujo:
 *  1. Recibe { email } en el body.
 *  2. Consulta Firestore en 'users' donde 'email' == email.
 *     - Si encuentra al menos un documento, responde { exists: true }.
 *     - Si no encuentra, responde { exists: false }.
 *  3. Si ocurre un error, responde 500 { error: 'Error al verificar el correo.' }.
 */
exports.checkIfUserExists = functions
  .region("europe-west3")
  .https.onRequest(async (req, res) => {
    const email = req.body.email;

    try {
      // Verificación en la colección de "users" si el email existe.
      const usersSnapshot = await admin
        .firestore()
        .collection("users")
        .where("email", "==", email)
        .limit(1)
        .get();

      if (!usersSnapshot.empty) {
        // Si se encuentran al menos un documento, el usuario existe.
        return res.status(200).send({ exists: true });
      } else {
        return res.status(200).send({ exists: false });
      }
    } catch (error) {
      console.error("Error verificando el correo:", error);
      return res.status(500).send({ error: "Error al verificar el correo." });
    }
  });

/**
 * Actualización del nombre de un cliente en Stripe y en Firestore.
 *
 * Ruta: POST https://<proyecto>.cloudfunctions.net/updateCustomerName
 *
 * Flujo:
 *  1. Recibe { customerId, newName } en el body.
 *  2. Si falta alguno, responde 400 { error: "Debe proporcionar el customerId y el newName." }.
 *  3. Actualiza el objeto Customer en Stripe: stripe.customers.update(customerId, { name: newName }).
 *  4. Busca en Firestore el documento en 'users' donde 'stripeCustomerId' == customerId.
 *     - Si no existe, responde 404 { error: "No se encontró el usuario en Firestore..." }.
 *     - Si existe, actualiza el campo 'name' en ese documento.
 *  5. Responde 200 { message: "...", stripeCustomer: <objetoActualizado> }.
 *  6. Si ocurre un error, responde 500 { error: "Error al actualizar el nombre en Stripe o Firestore" }.
 */
exports.updateCustomerName = functions
  .region("europe-west3")
  .https.onRequest(async (req, res) => {
    const { customerId, newName } = req.body;

    console.log("Datos recibidos:", { customerId, newName });

    if (!customerId || !newName) {
      console.log("Faltan customerId o newName.");
      return res
        .status(400)
        .send({ error: "Debe proporcionar el customerId y el newName." });
    }

    try {
      const updatedCustomer = await stripe.customers.update(customerId, { name: newName });
      console.log("Nombre actualizado en Stripe:", updatedCustomer);

      // Buscar usuario en Firestore por stripeCustomerId
      const userSnapshot = await admin
        .firestore()
        .collection("users")
        .where("stripeCustomerId", "==", customerId)
        .limit(1)
        .get();

      if (userSnapshot.empty) {
        console.log("No se encontró el usuario en Firestore.");
        return res
          .status(404)
          .send({ error: "No se encontró el usuario en Firestore con ese customerId." });
      }

      const userDoc = userSnapshot.docs[0];
      await userDoc.ref.update({ name: newName });
      console.log("Nombre actualizado en Firestore para el usuario con ID:", userDoc.id);

      res.status(200).send({
        message: "Nombre actualizado correctamente en Stripe y Firestore",
        stripeCustomer: updatedCustomer,
      });
    } catch (error) {
      console.error("Error al actualizar:", error);
      res.status(500).send({ error: "Error al actualizar el nombre en Stripe o Firestore" });
    }
  });

/**
 * Registro de la solicitud de eliminación de cuenta.
 *
 * Ruta: POST https://<proyecto>.cloudfunctions.net/requestAccountDeletion
 *
 * Flujo:
 *  1. Solo acepta método POST; si llega otro, responde 405 { error: "Método no permitido. Usa POST." }.
 *  2. Extrae token Bearer del header Authorization; si no existe, responde 401.
 *  3. Verifica el token JWT con admin.auth().verifyIdToken(token); extrae uid.
 *  4. Si falta req.body.stripeCustomerId, responde 400 { error: "stripeCustomerId no proporcionado..." }.
 *  5. Consulta en Firestore en `users/{uid}/userOrderRecord` donde 'orderState' != 'received'.
 *     - Si existe al menos un doc, responde 400 { error: "No puedes solicitar la eliminación..." }.
 *  6. Crea documento `accountDeletionRequests/{uid}` con { stripeCustomerId, requestedAt }.
 *  7. Responde 200 { success: true, message: "Solicitud registrada..." }.
 *  8. Si ocurre un error, responde 500 con mensaje de error genérico.
 */
exports.requestAccountDeletion = functions
  .region("europe-west3")
  .https.onRequest(async (req, res) => {
    if (req.method !== "POST") {
      return res.status(405).send({ error: "Método no permitido. Usa POST." });
    }

    const authHeader = req.headers.authorization || "";
    const token = authHeader.startsWith("Bearer ")
      ? authHeader.split("Bearer ")[1]
      : null;

    if (!token) {
      return res.status(401).send({ error: "Token de autenticación no proporcionado." });
    }

    try {
      // Verificación del token y obtención del UID del usuario
      const decodedToken = await admin.auth().verifyIdToken(token);
      const userId = decodedToken.uid;

      if (!req.body.stripeCustomerId) {
        return res
          .status(400)
          .send({ error: "stripeCustomerId no proporcionado en el cuerpo de la solicitud." });
      }

      const stripeCustomerId = req.body.stripeCustomerId;
      const db = admin.firestore();

      // Verificación de si el usuario tiene pedidos pendientes
      const ordersSnapshot = await db
        .collection("users")
        .doc(userId)
        .collection("userOrderRecord")
        .where("orderState", "!=", "received")
        .get();

      if (!ordersSnapshot.empty) {
        return res.status(400).send({
          error: "No puedes solicitar la eliminación de la cuenta mientras tienes pedidos pendientes.",
        });
      }

      // Registro de la solicitud de eliminación en Firestore
      const deletionRequest = {
        stripeCustomerId,
        requestedAt: admin.firestore.Timestamp.now(),
      };

      await db.collection("accountDeletionRequests").doc(userId).set(deletionRequest);

      console.log(`Solicitud de eliminación registrada para el usuario ${userId}.`);
      return res.status(200).send({
        success: true,
        message: "Solicitud de eliminación registrada exitosamente. La cuenta será eliminada en 30 días.",
      });
    } catch (error) {
      console.error("Error al registrar la solicitud de eliminación:", error);
      return res.status(500).send({
        error: "Ocurrió un error al intentar registrar la solicitud. Inténtalo más tarde.",
      });
    }
  });

/**
 * Eliminación de las cuentas solicitadas que han pasado 30 días desde la solicitud.
 *
 * Trigger: Cron (Pub/Sub) programado para ejecutarse “every 24 hours”.
 *
 * Flujo:
 *  1. Calcula timestamp de hace 30 días.
 *  2. Consulta Firestore en `accountDeletionRequests` donde requestedAt <= thirtyDaysAgo.
 *  3. Si no hay documentos, hace log y retorna.
 *  4. Para cada doc:
 *     a) Obtiene stripeCustomerId y userId (doc.id).
 *     b) Elimina cliente en Stripe con stripe.customers.del(stripeCustomerId).
 *     c) Recorre subcolecciones ["userOrderRecord","cartProducts","pointsHistory"] en users/{userId}:
 *        - Por cada subcolección, elimina todos los documentos.
 *     d) Elimina el documento principal del usuario en `users/{userId}`.
 *     e) Elimina la cuenta de Firebase Auth con admin.auth().deleteUser(userId).
 *     f) Elimina la solicitud de eliminación (doc en accountDeletionRequests).
 *  5. Si ocurre un error en un usuario, lo loggea y continúa con los demás.
 */
exports.deleteExpiredAccounts = functions
  .region("europe-west3")
  .pubsub.schedule("every 24 hours")
  .onRun(async () => {
    const db = admin.firestore();
    const thirtyDaysAgo = admin.firestore.Timestamp.fromMillis(
      Date.now() - 30 * 24 * 60 * 60 * 1000
    );

    try {
      const snapshot = await db
        .collection("accountDeletionRequests")
        .where("requestedAt", "<=", thirtyDaysAgo)
        .get();

      if (snapshot.empty) {
        console.log("No hay cuentas para eliminar.");
        return;
      }

      const deletePromises = snapshot.docs.map(async (doc) => {
        const { stripeCustomerId } = doc.data();
        const userId = doc.id;

        try {
          // Eliminación del cliente de Stripe
          if (stripeCustomerId) {
            await stripe.customers.del(stripeCustomerId);
            console.log(`Cliente de Stripe ${stripeCustomerId} eliminado exitosamente.`);
          }

          // Eliminación de las subcolecciones en Firestore
          const subcollections = ["userOrderRecord", "cartProducts", "pointsHistory"];
          for (const subcollection of subcollections) {
            const subcollectionSnapshot = await db
              .collection("users")
              .doc(userId)
              .collection(subcollection)
              .get();
            const deletePromises = subcollectionSnapshot.docs.map((d) =>
              d.ref.delete()
            );
            await Promise.all(deletePromises);
          }

          // Eliminación documento principal del usuario
          await db.collection("users").doc(userId).delete();

          // Eliminación de la cuenta de Firebase Auth
          await admin.auth().deleteUser(userId);

          // Eliminación de la solicitud de eliminación
          await doc.ref.delete();

          console.log(`Cuenta para el usuario ${userId} eliminada exitosamente.`);
        } catch (error) {
          console.error(`Error al eliminar la cuenta del usuario ${userId}:`, error);
        }
      });

      await Promise.all(deletePromises);
      console.log("Proceso de eliminación completado.");
    } catch (error) {
      console.error("Error durante el proceso de eliminación:", error);
    }
  });

/**
 * Listar métodos de pago (PaymentMethods) de tipo “card” asociados a un cliente.
 *
 * Ruta: GET https://<proyecto>.cloudfunctions.net/paymentMethods?customerId=<cus_…>
 *
 * Flujo:
 *  1. Extrae customerId de req.query.
 *     - Si no existe, responde 400 { error: "Falta customerId" }.
 *  2. Llama a stripe.paymentMethods.list({ customer: customerId, type: "card" }).
 *  3. Mapea cada PaymentMethod a un objeto con:
 *     {
 *       id, brand, last4, expMonth, expYear, isDefault:false
 *     }
 *  4. Recupera el objeto Customer en Stripe y obtiene default_payment_method.
 *  5. Marcar isDefault=true para el método cuyo id coincida con default_payment_method.
 *  6. Responde 200 { paymentMethods: <arrayConDefault> }.
 *  7. Si ocurre un error, responde 500 con { error: err.message }.
 */
exports.paymentMethods = functions
  .region("europe-west3")
  .https.onRequest(async (req, res) => {
    try {
      const customerId = req.query.customerId;
      if (!customerId) {
        return res.status(400).json({ error: "Falta customerId" });
      }

      // 1. Listar todos los PaymentMethods de tipo “card” asociados a ese cliente
      const pmList = await stripe.paymentMethods.list({
        customer: customerId,
        type: "card",
      });

      // 2. Transformar la respuesta para enviar solo la info necesaria al frontend
      const tarjetas = pmList.data.map((pm) => ({
        id: pm.id, // p. ej. "pm_1JX…"
        brand: pm.card.brand, // "visa", "mastercard", etc.
        last4: pm.card.last4, // últimos 4 dígitos
        expMonth: pm.card.exp_month, // mes de expiración (número)
        expYear: pm.card.exp_year, // año de expiración (número)
        isDefault: false, // luego marcaremos cuál es el default
      }));

      // 3. Obtener el default_payment_method del cliente (si existe)
      const customer = await stripe.customers.retrieve(customerId);
      const defaultPmId = customer.invoice_settings?.default_payment_method || null;

      // 4. Marcar en el array cuál es el default
      const tarjetasConDefault = tarjetas.map((t) => ({
        ...t,
        isDefault: t.id === defaultPmId,
      }));

      return res.json({ paymentMethods: tarjetasConDefault });
    } catch (err) {
      console.error("Error en paymentMethods:", err);
      return res.status(500).json({ error: err.message });
    }
  });

/**
 * Establecer un método de pago como predeterminado para un cliente.
 *
 * Ruta: POST https://<proyecto>.cloudfunctions.net/setDefaultMethod
 *
 * Flujo:
 *  1. Recibe { customerId, paymentMethodId } en el body.
 *     - Si falta alguno, responde 400 { error: "Faltan customerId o paymentMethodId" }.
 *  2. Llama a stripe.customers.update(customerId, { invoice_settings: { default_payment_method: paymentMethodId } }).
 *  3. Responde 200 { success: true }.
 *  4. Si ocurre un error, responde 500 { error: err.message }.
 */
exports.setDefaultMethod = functions
  .region("europe-west3")
  .https.onRequest(async (req, res) => {
    try {
      const { customerId, paymentMethodId } = req.body;
      if (!customerId || !paymentMethodId) {
        return res.status(400).json({ error: "Faltan customerId o paymentMethodId" });
      }

      // Actualizar el Customer para que tenga ese PM como default en facturación
      await stripe.customers.update(customerId, {
        invoice_settings: {
          default_payment_method: paymentMethodId,
        },
      });

      return res.json({ success: true });
    } catch (err) {
      console.error("Error en setDefaultMethod:", err);
      return res.status(500).json({ error: err.message });
    }
  });

/**
 * Desasociar (eliminar) un método de pago de un cliente.
 *
 * Ruta: POST https://<proyecto>.cloudfunctions.net/removeMethod
 *
 * Flujo:
 *  1. Recibe { paymentMethodId } en el body.
 *     - Si falta, responde 400 { error: "Falta paymentMethodId" }.
 *  2. Llama a stripe.paymentMethods.detach(paymentMethodId).
 *  3. Responde 200 { success: true }.
 *  4. Si ocurre un error, responde 500 { error: err.message }.
 */
exports.removeMethod = functions
  .region("europe-west3")
  .https.onRequest(async (req, res) => {
    try {
      const { paymentMethodId } = req.body;
      if (!paymentMethodId) {
        return res.status(400).json({ error: "Falta paymentMethodId" });
      }
      // Desasociar el PM del cliente:
      await stripe.paymentMethods.detach(paymentMethodId);
      return res.json({ success: true });
    } catch (err) {
      console.error("Error en removeMethod:", err);
      return res.status(500).json({ error: err.message });
    }
  });

/**
 * Creación de una sesión de Stripe Checkout usando price_data.
 *
 * Ruta: POST https://<proyecto>.cloudfunctions.net/createCheckoutSession
 *
 * Flujo:
 *  1. Solo acepta método POST; si llega otro, responde 405 { error: "Método no permitido, usa POST." }.
 *  2. Recibe en el body: { customerId?, currency, items, successUrl, cancelUrl }.
 *     - items debe ser un arreglo no vacío con objetos { name, unitAmount, quantity }.
 *     - Si falta algún campo obligatorio, responde 400 con el error correspondiente.
 *  3. Convierte cada item a un line_item con price_data:
 *     - unit_amount = Math.round(unitAmount * 100)  // céntimos
 *     - currency: currency
 *     - product_data: { name: item.name }
 *     - quantity: item.quantity
 *  4. Construye sessionParams con:
 *     {
 *       payment_method_types: ["card"],
 *       line_items: stripeLineItems,
 *       mode: "payment",
 *       success_url: successUrl,
 *       cancel_url: cancelUrl,
 *       customer: customerId?  // opcional
 *     }
 *  5. Llama a stripe.checkout.sessions.create(sessionParams).
 *  6. Responde 200 { url: session.url }.
 *  7. Si ocurre un error, responde 500 { error: error.message }.
 */
exports.createCheckoutSession = functions
  .region("europe-west3")
  .https.onRequest(async (req, res) => {
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Método no permitido, usa POST." });
    }

    try {
      const { customerId, currency, items, successUrl, cancelUrl } = req.body;

      // Validaciones básicas
      if (!Array.isArray(items) || items.length === 0) {
        return res.status(400).json({ error: "Debes enviar al menos un producto en items." });
      }
      if (!currency) {
        return res.status(400).json({ error: "Falta la moneda (currency)." });
      }
      if (!successUrl || !cancelUrl) {
        return res.status(400).json({ error: "Debes proporcionar successUrl y cancelUrl." });
      }

      // Construir line_items con price_data
      const stripeLineItems = items.map(item => {
        // item.unitAmount es un double (ej: 15.99 en euros)
        const amountInCents = Math.round(item.unitAmount * 100);
        return {
          price_data: {
            currency: currency,
            product_data: {
              name: item.name, // nombre que quieras mostrar en Checkout
            },
            unit_amount: amountInCents,
          },
          quantity: item.quantity,
        };
      });

      const sessionParams = {
        payment_method_types: ["card"],
        line_items: stripeLineItems,
        mode: "payment",
        success_url: successUrl,
        cancel_url: cancelUrl,
      };
      if (customerId) {
        sessionParams.customer = customerId;
      }

      // Crear sesión en Stripe
      const session = await stripe.checkout.sessions.create(sessionParams);
      return res.status(200).json({ url: session.url });
    } catch (error) {
      console.error("Error creando Checkout Session con price_data:", error);
      return res.status(500).json({ error: error.message });
    }
  });



