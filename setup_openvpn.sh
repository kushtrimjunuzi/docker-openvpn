#!/bin/bash

OVPN_DATA="ovpn-data"
NAME="ovpn"

CMD=$1
USERNAME=$2

cmd_install(){
        docker run --name $OVPN_DATA -v /etc/openvpn busybox
        docker run --volumes-from $OVPN_DATA --rm kushtrimjunuzi/openvpn:arm32v6 ovpn_genconfig -u udp://vpn.identakid.net
        docker run --volumes-from $OVPN_DATA --rm -it kushtrimjunuzi/openvpn:arm32v6 ovpn_initpki
        docker run --name $NAME --volumes-from $OVPN_DATA -d -p 1194:1194/udp --cap-add=NET_ADMIN kushtrimjunuzi/openvpn:arm32v6
         #docker run --volumes-from $OVPN_DATA -d -p 1194:1194/udp --privileged -e DEBUG=1 kushtrimjunuzi/openvpn:arm32v6
}

cmd_new_user(){
        docker run --volumes-from $OVPN_DATA --rm -it kushtrimjunuzi/openvpn:arm32v6 easyrsa build-client-full $USERNAME
        docker run --volumes-from $OVPN_DATA --rm kushtrimjunuzi/openvpn:arm32v6 ovpn_getclient $USERNAME > $USERNAME.ovpn
}

cmd_revoke_user(){
        docker exec -it $NAME easyrsa revoke $USERNAME
        docker exec -it $NAME easyrsa gen-crl
}


case "$CMD" in
        install)
                cmd_install
                ;;
        new-user)
                cmd_new_user
                ;;
        revoke-user)
                cmd_revoke_user
                ;;
        *)
        echo $"Usage: $0 {install|new-user username|revoke-user username}"
        exit 1
esac

