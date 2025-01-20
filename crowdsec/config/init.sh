#!/bin/bash
CREDENTIALS_FILE="/etc/crowdsec/local_api_credentials.yaml"
if [ ! -f "$CREDENTIALS_FILE" ]; then
    echo "Generating new bouncer credentials..."
    
    BOUNCER_KEY=$(cscli bouncers add nginx-bouncer -o raw)
    
    cat > "$CREDENTIALS_FILE" << EOF
BOUNCER_KEY: ${BOUNCER_KEY}
EOF

    chmod 640 "$CREDENTIALS_FILE"
else
    echo "Using existing bouncer credentials"
fi

crowdsec -c /etc/crowdsec/config.yaml