const { create } = require('@open-wa/wa-automate');
const { LAUNCH_CONFIG, LLM_URL } = require('./config')

// Only process message having length more then 46
const WORD_LEN_TRSH = 46;

function start(client) {
  client.onMessage(async message => {
    const messageId = message.id;
    const from = message.from
    const text = message.body
    const author = message.author // Author and from can be different in case of group;
    const message_type = message.type

    // Calling the LLM api to analyze the text
    if(message_type==="chat" && text.length>=WORD_LEN_TRSH){
        
      let msg = await fetch(
          LLM_URL,{
          method:"POST",
          body: JSON.stringify({ input: text })
      })
      let response = await msg.json()
      
      // await client.sendText(from, response===0?"Safe":"Ad"); 
      
      if(response){
        try{
          await client.deleteMessage(messageId);
          // For debugging purpose
          // await client.sendText(from, 'Chat deleted successfully.');

          // Sending the sender that you have sent Ad message in wrong group
          await client.sendText(author, 'Please donot send Ads to the support group.');

        } catch (error) {
          console.error('[X] Log: Failed to delete chat error:', error);
        }
      }

    }

    else{
      // Handle for not message type == chat
    }
    
  });
}

  
create(LAUNCH_CONFIG).then(start);