19-05-2025
- One more thing top bar padding move english companion text to the left. completed.
- Improve the ui for the voice to voice conversation According to how i planned.
- Make voice to voice conversation persistant.
- Make response more better compare to how i am getting the answers.
- Improve the icons for the theme module. and Ui transition from the dark to light and light to dark theme should be smooth.
- During the voice module i am not converting the voice to text so i have to do it also and also not showing.
- Side bar module is different than the current ui color theme so have to match the color theme of the app.

20-05-2025
- First have to add the home screen just to make it have the core functionality of chat module.
- After that Have to add the login and sign up module same as the jewelify and integrate it into the English companion.
- Have to add loading screen which shows that how to use the core modules of the app like noraml chat module, voice module etc. But this is going to be useful when i add the formal, informal caht and voice module also. I think this will might be needed or not also as this app is going to be neat and clean and also the user friendly also.


23-05-2025
First, I'll create a foundational Grammar page.
Next, I'll develop a Parts of Speech page detailing common nouns, verbs, adjectives, etc., with examples.
Then, I'll make a Sentence Structure page covering basic patterns and types used in conversation.
I'll create a Vocabulary page with commonly used words, their meanings, and example sentences for daily conversation.
After that, I'll make an Articles page featuring frequently used articles (a, an, the) with meanings and examples for everyday use.
Subsequently, I'll develop a WH Questions page covering common interrogatives with meanings and examples for daily conversations.
Then, I'll make a Prepositions page for commonly used prepositions, including their meanings and example sentences for daily use.
I'll create a Tenses page focusing on frequently used verb tenses with meanings and examples for everyday conversation.
Next, I'll develop a Modals page for common modal verbs (can, should, will, etc.) with examples of their use in conversation.
I'll also create a Conjunctions and Connectors page to show how to link ideas smoothly.
(Optional, but useful: I could add a Reported Speech page.)
Finally, I'll create a Quiz page covering all modules: grammar fundamentals, parts of speech, sentence structure, vocabulary, articles, WH questions, prepositions, tenses, modals, and connectors.
--------------------------------



- Make sure to show speak now or listening only when audio is being recorded otherwise when sytem is speaking write system is speaking or something like that. and when when it is processing i will show the message that processing the audio.
- if system is not able to record the audio then show the message that system is not able to record the audio and do not show the message that speak now listening ok.
- Make proper error handling for above cases and also handle how to tell the system that it is not able to record the audio and it is right now playing the response got from the server.


27-05-2025
- I added login and registration Screen and only frontend is completed but server is not generated yet.
- Image in the login and registration screen is not added to any of the pages and have remove the button showing in the registration page in the left top corner.
- Have to start using the poppins text into the whole application.

-------------------
- as you know every time i conncet my mobile to my laptop using the laptop hotspot and trying to conncet to the server of the application it is always showing the error that connection failed so i have to change the ip address in the .env file of the application every time but some time it works and some times not.
- # BACKEND_URL=http://172.28.240.1:8000
# BACKEND_URL=http://192.168.31.81:8000
# BACKEND_URL=http://172.28.128.1:8000
# BACKEND_URL=http://172.19.80.1:8000
BACKEND_URL=http://192.168.137.1:8000
# BACKEND_URL=http://172.30.176.1:8000
# BACKEND_URL=http://192.168.137.1:8000
see only one is not commented and for that uri i am getting the {"status":"ok","timestamp":"2025-05-27T09:17:26.664875","service":"English Companion API","version":"1.0.0"} this in the browser and postman but when i try to connect to the server of the application it is showing the error that connection failed. so make such solution which can help me to connect to the server of the application without changing the ip address in the .env file of the application every time and also make sure that it is working on all the devices.
 