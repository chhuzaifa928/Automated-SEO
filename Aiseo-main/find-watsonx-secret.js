const axios = require('axios');
const dotenv = require('dotenv');
dotenv.config();

const API_KEY = process.env.WATSONX_API_KEY;
const INSTANCE_ID = "919dc40a-d9fd-42b0-8bfd-15fca422a942";
const IAM_URL = "https://iam.cloud.ibm.com/identity/token";
const CONFIG_URL = `https://api.eu-gb.watson-orchestrate.cloud.ibm.com/instances/${INSTANCE_ID}/v1/embed/secure/config`;

async function findSecret() {
    try {
        console.log('1. Getting IAM Token...');
        const tokenRes = await axios.post(IAM_URL, `grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=${API_KEY}`, {
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        });
        const token = tokenRes.data.access_token;

        console.log('2. Fetching Security Config...');
        const configRes = await axios.get(CONFIG_URL, {
            headers: { 'Authorization': `Bearer ${token}` }
        });

        console.log('\n========================================');
        console.log('WATSONX SECURITY CONFIG FOUND!');
        console.log('========================================');
        console.log('Is Security Enabled:', configRes.data.is_security_enabled);
        if (configRes.data.secret_key) {
            console.log('YOUR SECRET KEY IS:', configRes.data.secret_key);
            console.log('\nCopy this key into your .env as WATSONX_INSTANCE_SECRET');
        } else if (configRes.data.private_key) {
            console.log('YOUR PRIVATE KEY IS:', configRes.data.private_key);
            console.log('\nCopy this key into your .env as WATSONX_INSTANCE_SECRET');
        } else {
            console.log('No secret key found in response. Trying to disable security instead...');
            await axios.post(CONFIG_URL, { is_security_enabled: false }, {
                headers: { 'Authorization': `Bearer ${token}` }
            });
            console.log('SUCCESS: Security has been DISABLED via API.');
        }
        console.log('========================================\n');

    } catch (err) {
        console.error('Error:', err.response ? err.response.data : err.message);
    }
}

findSecret();
