require('dotenv').config();
const cors = require('cors');
const express = require('express');
const stripe = require('stripe')('sk_test_51OsMYXSFnYhx5DszZOSxnFEUJlc0Nq8BFYPVsVsRgRlIlebNP3w1XHAbceWro1P0PmeymTWmlbHEObA8VSjXH6pF00zunyInhC');
const bodyParser = require('body-parser');

const app = express();

// Enable CORS for all routes and origins
app.use(cors());

// Endpoint to create a customer and save a payment method
// Node.js: Creating a customer
app.post('create-customer', async (req, res) => {
  const { email } = req.body; // Assuming email is passed from the client
  try {
    const customer = await stripe.customers.create({
      email: email,
      // You can add more details here as needed
    });
    res.json(customer);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
// Node.js: Attaching a payment method to a customer
app.post('/attach-payment-method', async (req, res) => {
  const { paymentMethodId, customerId } = req.body;
  try {
    const paymentMethod = await stripe.paymentMethods.attach(paymentMethodId, {
      customer: customerId,
    });
    // Optionally, set this payment method as the default for invoices
    await stripe.customers.update(customerId, {
      invoice_settings: {
        default_payment_method: paymentMethodId,
      },
    });
    res.json(paymentMethod);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const port = process.env.PORT || 54992;
app.listen(port, () => console.log(`Server listening on port ${port}`));
//app.listen(port, () => {
//  console.log(`Server listening at http://localhost:${port}`);
//});
