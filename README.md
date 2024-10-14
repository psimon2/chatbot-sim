# About this Repository

This repository contains a web application that simulates a chatbot interaction for clinicians.

The web app uses a REST interface to deliver dialogue to the user.

## Features

### Feature 1: Text-Only Conversations

The web service supports simple, back-and-forth text conversations. It uses a list of medical keywords to determine if the user is engaging in a text-based conversation. These keywords are stored in the `mr-terms.txt` file.

The server checks if any words in the user's request match the terms in `mr-terms.txt`. Depending on the match, the server responds with:
- **"No, I could not find anything in the record"**, or
- **"Yes, it's in their record"**.

### Feature 2: Highlighting Phrases in Patient Notes

The chatbot can retrieve patient notes with specific phrases or words highlighted in its responses. Users can delete certain highlights if they are incorrect or irrelevant. To do this:
- A hovering delete button appears near each highlighted word, allowing users to remove it.
- When clicked, the highlight disappears.

If the user types "highlight", the server returns a random sample of up to five current or previously prescribed medications, with the option to remove highlights using red crosses.

For example, a user might ask:  
*"Give me the patient’s discharge letter with all medications highlighted."*

Once a user finishes editing highlights, typing "insert", "save", "file", or "update" will trigger the response **"Sure"**—but only if some deletions were made during the current session. Refreshing the browser will generate a new session ID.

### Feature 3: Generating Charts

The chatbot can generate a line graph, based on user requests. If a user includes "chart" or "graph" in their request, the system will check for time-based keywords like "last" and "from."

For example:
- *"Please graph the last 10 days from 1.1.2020"* would generate a random sample of admissions from December 23, 2021, to January 1, 2020.
- *"Please chart the last 5 days"* would display a sample from today to 5 days ago.

If the system can't interpret the request, it responds:  
**"Machine: You asked for a chart, but didn't specify the time range. For example, ask me to show a graph for the last 10 days."**

The graph feature supports time ranges of up to 10 days or 12 months.

If the system doesn't understand a user's question, it replies:  
**"Sorry, I did not understand your question."**

The UI also includes a floating arrow for quick scrolling to the bottom of the message history.

## Web Services

A lightweight version of these web services is written in Python using the FastAPI library, which serves static content similar to the ASSIGN web services. This could easily be extended to support the entire REST interface used by the web app.

The software has been tested on Chrome, Firefox (Windows desktop), and Android devices.

## Installation

### Web Services:

Refer to the following links for installation instructions on Ubuntu:

- [Pre-Requisites](https://github.com/endeavourhealth-discovery/ASSIGN/blob/master/documentation/Pre_Requisites.md)
- [YottaDB Installation](https://github.com/endeavourhealth-discovery/ASSIGN/blob/master/documentation/YottaDB_Install.md)
- [ASSIGN Installation](https://github.com/endeavourhealth-discovery/ASSIGN/blob/master/documentation/ASSIGN_Install.md)

After setting up, restore `CHATBOT.m` into the YottaDB system hosting the web services and run:
```
ydb -run %XCMD 'do MRTERMS^CHATBOT'
```
Create a new directory under the srv folder called chatbot.
Copy script.js, styles.css, and index.html to /srv/chatbot/.
Then navigate to:
```
http://{host}/srv/chatbot/
```
Example host:
```
http://192.168.178.23:9080/srv/chatbot/
```
### Web Services (Python):
Install FastAPI and Uvicorn:
```
pip install fastapi
sudo apt install uvicorn
````
To launch the web services:
```
uvicorn main:app --reload --host 0.0.0.0 --port 8080
```
The --host 0.0.0.0 option allows you to access the site from any device on the network, not just localhost.

### Testing the Python Web Services:
- Download the source code from [here](https://github.com/luciopanepinto/pacman)
- Copy the pacman code to the srv directory.
- Navigate to:
```
http://{host}:8080/srv/pacman-master/index.html
````
