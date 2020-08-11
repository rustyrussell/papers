#! /bin/sh

VENDORS="030c3f19d742ca294a55c00376b3b355c3c90d61c6b6b39554dbc7ac19b141c14f 02df5ffe895c778e10f7742a6c5b8a0cefbe9465df58b92fadeb883752c8107c8f 03c2abfa93eacec04721c019644584424aab2ba4dff3ac9bdab4e9c97007491dda 03abf6f44c355dec0d5aa155bdbdd6e0c8fefe318eff402de65c6eb2e1be55dc3e 02004c625d622245606a1ea2c1c69cfb4516b703b47945a3647713c05fe4aaeb1c"

PEERS="02001828ca7eb8e44d4d78b5c1ea609cd3744be823c22cd69d895eff2f9345892d 020177ac03d9e75d6190dfa147e9cb3e5905a2e02048151f1fc9cc5a72a3cd60f0 0201fa3eccc87826765f52afc5906d90a6c3598f49f3e0a9d90d612597c37a2fd5 0202e6bffec1e453d3cd93917d65544a7a87c88f1a6c52ed827a3cb7157bb06e93 020328dfec863a339a91f16e50082768b97f87abbbe7b7b9dd2a150d0b0409b49f"

STORE=gossip-store-2020-07-27

for n in $VENDORS; do
    echo $n: >&2
    ~/devel/cvs/lightning/devtools/topology $STORE all $n 2>&1 | grep -v 'ignored: fee'
done > /tmp/topo-vendors

for n in $PEERS; do
    echo $n: >&2
    ~/devel/cvs/lightning/devtools/topology $STORE all $n 2>&1 | grep -v 'ignored: fee'
done  > /tmp/topo-peers

for n in $VENDORS; do
    echo $n: >&2
    ~/devel/cvs/lightning/devtools/topology --no-single-sources $STORE all $n 2>&1 | grep -v 'ignored: fee'
done > /tmp/topo-vendors-nosingles

for f in vendors peers vendors-nosingles; do
    echo $f:
    for p in `seq 100`; do
	COUNT=`grep -c "^# path length $p\$" /tmp/topo-$f`
	[ $COUNT != 0 ] || break
	echo "Path length $p: ($COUNT nodes)"
	for h in `seq $p`; do
	    grep "source set size node $h/$p:" /tmp/topo-$f | stats
	done
	for h in `seq $p`; do
	    grep "destination set size node $((h - 1))/$p:" /tmp/topo-$f | stats
	done
    done
done
