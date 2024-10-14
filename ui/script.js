// Generate session ID when the page is first loaded
let sessionId = generateSessionId();

function generateSessionId() {
    return '_' + Math.random().toString(36).substr(2, 9);
}

// Handle chat logic, highlighting, and chart generation
document.getElementById("send-btn").addEventListener("click", sendMessage);

let chatBox = document.getElementById("chat-box");
let scrollBtn = document.getElementById("scroll-to-bottom-btn");
let apiUrl = '/chatbot/run';
let errorAlert = document.getElementById("error-alert");

chatBox.addEventListener('scroll', handleScroll);

function sendMessage() {
    let input = document.getElementById("chat-input").value.trim();
    if (input) {
        addMessage("Clinician", input);
        processInput(input);
        document.getElementById("chat-input").value = '';
        errorAlert.classList.add("d-none");
    } else {
        showError("Please enter a message.");
    }
}

function addMessage(sender, message) {
    let messageDiv = document.createElement("div");
    messageDiv.textContent = `${sender}: ${message}`;
    messageDiv.classList.add('mb-2');
    
    // Add the message to the chat box
    chatBox.appendChild(messageDiv);

    // Scroll to bottom only if the user is at the bottom
    scrollToBottom();
}

function scrollToBottom() {
    chatBox.scrollTop = chatBox.scrollHeight;
}

// Show the "scroll to bottom" button when the user scrolls up
function handleScroll() {
    let isAtBottom = chatBox.scrollHeight - chatBox.scrollTop <= chatBox.clientHeight + 50;
    
    if (isAtBottom) {
        scrollBtn.classList.add("d-none");
    } else {
        scrollBtn.classList.remove("d-none");
    }
}

// Scroll to the bottom when the button is clicked
scrollBtn.addEventListener('click', scrollToBottom);

function processInput(input) {
    fetch(apiUrl, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ 
            message: input,
            sessionId: sessionId // Include session ID in the request
        })
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Failed to fetch response from the server.');
        }
        return response.json();
    })
    .then(data => {
        if (data.type === 'text') {
            addMessage('Machine', data.response);
        } else if (data.type === 'highlight') {
            showHighlightedText(data.response);
        } else if (data.type === 'chart') {
            showChart(data.chartData);
        }
    })
    .catch(error => {
        showError(error.message);
    });
}

function showError(message) {
    errorAlert.textContent = message;
    errorAlert.classList.remove("d-none");
}

// Feature 2: Show highlighted text with delete option
function showHighlightedText(text) {
    let container = document.createElement("div");
    container.classList.add('my-3'); // Add some spacing

    text.forEach(fragment => {
        let span = document.createElement("span");
        
        // Create the delete button for highlighted text
        if (fragment.highlighted) {
            span.classList.add("highlight");
            
            let deleteBtn = document.createElement("span");
            deleteBtn.textContent = "✕ ";
            deleteBtn.classList.add("delete-highlight", "me-1");
            deleteBtn.onclick = function() {
                span.classList.remove("highlight");
                deleteBtn.remove();
                // Additional logic if needed to handle deletion (e.g., notify the server)
            };

            span.appendChild(deleteBtn); // Add the delete button first
        }

        // Now add the text after the delete button
        let textNode = document.createTextNode(fragment.text);
        span.appendChild(textNode);
        span.classList.add('me-2'); // Add margin between fragments

        container.appendChild(span);
        container.appendChild(document.createTextNode(" ")); // Add space between fragments
    });

    chatBox.appendChild(container);

    // Scroll to the bottom after showing highlighted text
    scrollToBottom();
}

// Feature 3: Show chart (line chart, bar chart, etc.)
function showChart(chartData) {
    // Create a container for the chart
    let chartContainer = document.createElement("div");
    chartContainer.classList.add('my-3'); // Add some spacing

    // Create the canvas element for the chart
    let canvas = document.createElement("canvas");
    chartContainer.appendChild(canvas);

    // Append the container to the chat box
    chatBox.appendChild(chartContainer);

    // Render the chart
    new Chart(canvas, {
        type: 'line',
        data: {
            labels: chartData.labels,
            datasets: [{
                label: chartData.label,
                data: chartData.data,
                borderColor: 'rgba(75, 192, 192, 1)',
                fill: false,
            }]
        },
        options: {
            responsive: true,
            scales: {
                x: {
                    title: {
                        display: true,
                        text: 'Time'
                    }
                },
                y: {
                    title: {
                        display: true,
                        text: 'Value'
                    }
                }
            }
        }
    });

    // Scroll to the bottom after rendering the chart
    scrollToBottom();
}
