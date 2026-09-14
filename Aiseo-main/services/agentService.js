const axios = require('axios');
require('dotenv').config();

const WATSONX_API_KEY = process.env.WATSONX_API_KEY;
const WATSONX_SERVICE_URL = process.env.WATSONX_SERVICE_URL || 'https://eu-gb.watson-orchestrate.cloud.ibm.com';
const WATSONX_AGENT_ID = process.env.WATSONX_AGENT_ID || '09ad7868-a942-4ea8-9649-dad07d3e2f30';
const WATSONX_AGENT_ENV_ID = process.env.WATSONX_AGENT_ENV_ID || '60054b30-40d5-40a5-b0a7-0599e473026e';

/**
 * Exchange API Key for Bearer Token
 */
async function getBearerToken() {
    if (!WATSONX_API_KEY) {
        console.warn('WATSONX_API_KEY not found in environment variables.');
        return null;
    }

    try {
        const response = await axios.post('https://iam.cloud.ibm.com/identity/token', null, {
            params: {
                grant_type: 'urn:ibm:params:oauth:grant-type:apikey',
                apikey: WATSONX_API_KEY
            },
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Accept': 'application/json'
            }
        });

        return response.data.access_token;
    } catch (error) {
        console.error('Error fetching Watsonx bearer token:', error.message);
        return null;
    }
}

/**
 * Call Watsonx Orchestrate Agent to perform analysis
 * @param {string} prompt - The instructions for the agent
 */
async function callAgent(prompt) {
    const token = await getBearerToken();
    if (!token) {
        throw new Error('Authentication failed: Missing Watsonx API Key or invalid token.');
    }

    try {
        // Note: The endpoint and structure below are based on general IBM Watsonx Orchestrate REST API patterns.
        // They may need adjustment based on specific skill/agent configuration.
        const endpoint = `${WATSONX_SERVICE_URL}/orchestrate/v1/agents/${WATSONX_AGENT_ID}/environments/${WATSONX_AGENT_ENV_ID}/chat`;

        const response = await axios.post(endpoint, {
            input: {
                text: prompt
            }
        }, {
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            }
        });

        // Extract the content from the agent's response
        // Response structure varies; assuming a standard chat-like response here
        return response.data;
    } catch (error) {
        console.error('Error calling Watsonx agent:', error.message);
        if (error.response) {
            console.error('Response data:', error.response.data);
        }
        throw error;
    }
}

/**
 * Generate SEO Audit using AI Agent
 */
async function generateAISAudit(url, elements) {
    const prompt = `Analyze the SEO performance of this website: ${url}. 
  Current technical elements collected:
  Title: ${elements.title}
  Meta Description: ${elements.metaDescription}
  H1 Tags: ${elements.h1Tags.join(', ')}
  Word Count: ${elements.wordCount}
  Images without alt: ${elements.imagesWithoutAlt}

  Please provide a structured SEO audit in JSON format with:
  1. An overall score (0-100)
  2. A list of critical issues
  3. A list of recommendations
  4. A grade (A, B, C, D, or F)
  `;

    try {
        const result = await callAgent(prompt);
        // Parse result if needed, or return as is if the agent returns JSON
        return result;
    } catch (error) {
        console.warn('AI Audit failed, falling back to rule-based analysis.');
        return null;
    }
}

/**
 * Generate Keyword Suggestions using AI Agent
 */
async function generateAIKeywords(baseKeyword) {
    const prompt = `Generate a list of 10 relevant long-tail keyword suggestions for the base keyword: "${baseKeyword}".
  For each keyword, estimate:
  1. Search Volume (Monthly)
  2. Keyword Difficulty (Easy, Medium, Hard)
  3. Relevance Score (0-100)
  
  Format the output as a JSON array.`;

    try {
        const result = await callAgent(prompt);
        return result;
    } catch (error) {
        console.warn('AI Keyword Research failed, falling back to rule-based analysis.');
        return null;
    }
}

module.exports = {
    callAgent,
    generateAISAudit,
    generateAIKeywords
};
