// Global variables
let orderId = null;
let baseUrl = 'https://dev-sitex-1705224153.wix-development-sites.org'; // Update with your actual Wix site URL

// Initialize the app when the DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  console.log('Plugin loaded, attempting to connect to Wix Dashboard...');
  initializeApp();
});

// Initialize the app
function initializeApp() {
  console.log('🚀 Initializing plugin...');
  
  // Extract order ID from URL
  orderId = getOrderIdFromURL();
  if (orderId) {
    console.log(`✅ Found order ID in URL: ${orderId}`);
    displayOrderInfo(orderId);
  } else {
    console.error('❌ No order ID found in URL');
    showError('No order ID found in URL. Please open this app from the Wix Orders dashboard.');
  }
  
  // Add event listeners
  document.getElementById('fulfillButton').addEventListener('click', handleFulfillment);
}

// Extract order ID from URL parameters
function getOrderIdFromURL() {
  const urlParams = new URLSearchParams(window.location.search);
  return urlParams.get('orderId');
}

// Display order information
function displayOrderInfo(orderId) {
  document.getElementById('orderId').textContent = orderId;
  
  // Create a random tracking number for testing
  const randomTrackingNum = Math.floor(Math.random() * 10000000000000000000).toString();
  document.getElementById('trackingNumber').value = randomTrackingNum;
  console.log(`Tracking Number: ${randomTrackingNum}`);
  
  // Enable form fields and button
  document.getElementById('trackingNumber').disabled = false;
  document.getElementById('trackingCompany').disabled = false;
  document.getElementById('fulfillButton').disabled = false;
}

// Handle the fulfillment process
function handleFulfillment() {
  console.log('🚀 Starting fulfillment process...');
  
  // Get form values
  const trackingNumber = document.getElementById('trackingNumber').value;
  const trackingCompany = document.getElementById('trackingCompany').value;
  
  if (!trackingNumber) {
    showError('Please enter a tracking number');
    return;
  }
  
  // Disable the button to prevent multiple submissions
  document.getElementById('fulfillButton').disabled = true;
  
  // Show loading state
  document.getElementById('statusArea').innerHTML = '<div class="loading">Processing...</div>';
  
  // Prepare the data
  const data = {
    orderId: orderId,
    trackingNumber: trackingNumber,
    trackingCompany: trackingCompany || 'Default Carrier'
  };
  
  console.log(`Order ID: ${orderId}`);
  console.log(`Tracking Number: ${trackingNumber}`);
  
  // Try different methods to fulfill the order
  tryHTTPFunction(data)
    .catch(() => tryWebMethod(data))
    .catch(showFinalError);
}

// Try HTTP Function method
function tryHTTPFunction(data) {
  console.log('🔄 Trying HTTP Functions...');
  const url = `${baseUrl}/_functions/fulfillOrder`;
  
  return fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    mode: 'cors', // Important for cross-origin requests
    body: JSON.stringify(data)
  })
  .then(response => {
    if (!response.ok) {
      throw new Error(`HTTP Functions response not OK: ${response.status}`);
    }
    return response.json();
  })
  .then(result => {
    if (result.success) {
      showSuccess('Order fulfilled successfully using HTTP Functions');
      return result;
    } else {
      throw new Error(result.message || 'HTTP Functions call failed');
    }
  })
  .catch(error => {
    console.error('❌ HTTP Functions fetch error:', error);
    throw error; // Rethrow to try the next method
  });
}

// Try Web Method
function tryWebMethod(data) {
  console.log('🔄 Trying Web Method...');
  const url = `${baseUrl}/_api/fulfillment-webmethod/createOrderFulfillment`;
  
  return fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    mode: 'cors',
    body: JSON.stringify(data)
  })
  .then(response => {
    if (!response.ok) {
      throw new Error(`Web Method response not OK: ${response.status}`);
    }
    return response.json();
  })
  .then(result => {
    if (result.success) {
      showSuccess('Order fulfilled successfully using Web Method');
      return result;
    } else {
      throw new Error(result.message || 'Web Method call failed');
    }
  })
  .catch(error => {
    console.error('❌ Web Method fetch error:', error);
    throw error;
  });
}

// Show final error after all methods fail
function showFinalError(error) {
  console.error('❌ Final error:', error);
  showError('Failed to fulfill order. See console for details.');
  
  // Re-enable the button
  document.getElementById('fulfillButton').disabled = false;
}

// Show success message
function showSuccess(message) {
  const statusArea = document.getElementById('statusArea');
  statusArea.innerHTML = `<div class="success">${message}</div>`;
  
  // Re-enable the button after a delay
  setTimeout(() => {
    document.getElementById('fulfillButton').disabled = false;
  }, 3000);
}

// Show error message
function showError(message) {
  const statusArea = document.getElementById('statusArea');
  statusArea.innerHTML = `<div class="error">${message}</div>`;
}
