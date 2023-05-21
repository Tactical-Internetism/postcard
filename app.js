const supabaseClient = require('@supabase/supabase-js')
const bodyParser = require('body-parser');
const twilio = require('twilio');
const express = require('express')
require('dotenv').config()
const { MessagingResponse } = require('twilio').twiml;

const app = express()
const port = 3000

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

const supabase = supabaseClient.createClient("https://ajfdbcwkkbrqhcbuvbcj.supabase.co", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFqZmRiY3dra2JycWhjYnV2YmNqIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODQ2MDcxOTIsImV4cCI6MjAwMDE4MzE5Mn0.wrxu5FPskgh00BxWlxw1oKr5Z-DVDk20t8kLtJxr_Kc")

app.get('/', (req, res) => {
  res.send('Hello World of Postcard!')
})

app.post('/sms', twilio.webhook({validate: false}), async (req, res) => {
  console.log("message recieved")
  console.log(req.body.Body)
  const twiml = new MessagingResponse();

  const link = req.body.Body
  const note = req.body.Body
  const sender = req.body.From
  const fridge = req.body.To
  
  const { data, error } = await supabase
    .from('fridges')
    .select()
  
  const { data, error } = await supabase
    .from('senders')
    .select()


  const {error} = await supabase
    .from('messages')
    .insert({
      link: link,
      note: note,
      sender_id: sender,
      fridge_id: fridge
    })

  if (error) {
    console.log(error)
    twiml.message("Sorry, something went wrong. Try sending the item again.");
    res.type('text/xml').send(twiml.toString());
  } else {
  twiml.message('Thanks for sending this item!');
  res.type('text/xml').send(twiml.toString());
  }
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
