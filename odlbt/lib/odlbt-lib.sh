CONFIG=~/.odlbtconfig

if [[ -e ./config ]]; then
    CONFIG=./config
fi

if [[ -s $CONFIG ]]; then
    ONEZONE=$(jq -r '.onezone' $CONFIG)
    ONEPROVIDERS=$(jq '.oneproviders' $CONFIG)
fi

getCredential(){
    
    user=$1
    jq -r ".users.${user}.username + "\"":"\"" + .users.${user}.password" $CONFIG

}

getProviderIp(){
    
    providerName=$1
    echo $ONEPROVIDERS | jq -r ".${providerName}.ip"
    
}

getUserToken(){
    
    user=$1
    jq -r ".users.${user}.token" $CONFIG
    
}

createUserToken(){
    ###
    # createUserToken
    #
    # Generates and returns a token for the input user
    ###
    local userCredential=`getCredential $1`
    
    curl -ku ${userCredential} -X POST -d '' -H 'content-type: application/json' \
    https://${ONEZONE}:8443/api/v3/onezone/user/client_tokens \
        2> /dev/null | jq -r '.token'

}

