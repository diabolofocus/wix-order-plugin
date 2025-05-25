// Global variables
let orderId = null;
let baseUrl = 'https://dev-sitex-1705224153.wix-development-sites.org';

// Initialize the app when the DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
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
  
  // Enable form fields and button
  document.getElementById('trackingNumber').disabled = false;
  document.getElementById('trackingCompany').disabled = false;
  document.getElementById('fulfillButton').disabled = false;
}

// Handle the fulfillment process
async function handleFulfillment() {
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
  try {
    // First try HTTP Functions
    console.log('🔄 Trying HTTP Functions...');
    const functionResult = await applyTracking(data, 'function');
    if (functionResult.success) {
      showSuccess('Order fulfilled successfully using HTTP Functions');
      return;
    }
    
    // If HTTP Functions fail, try Web Method
    console.log('🔄 Trying Web Method...');
    const webMethodResult = await applyTracking(data, 'webmethod');
    if (webMethodResult.success) {
      showSuccess('Order fulfilled successfully using Web Method');
      return;
    }
    
    // If both methods fail, show error
    throw new Error('Both fulfillment methods failed');
    
  } catch (error) {
    console.error('❌ Final error:', error);
    showError('Failed to fulfill order. See console for details.');
    // Re-enable the button
    document.getElementById('fulfillButton').disabled = false;
  }
}

// Apply tracking information using specified method
async function applyTracking(data, method) {
  const endpoints = {
    'function': `${baseUrl}/_functions/fulfillOrder`,
    'webmethod': `${baseUrl}/_api/fulfillment-webmethod/createOrderFulfillment`
  };
  
  const url = endpoints[method];
  
  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      mode: 'cors', // Important for cross-origin requests
      body: JSON.stringify(data)
    });
    
    if (!response.ok) {
      throw new Error(`HTTP error! Status: ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    console.error(`❌ ${method === 'function' ? 'HTTP Functions' : 'Web Method'} fetch error:`, error);
    throw error;
  }
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
