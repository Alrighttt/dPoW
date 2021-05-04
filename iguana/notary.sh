#!/usr/bin/env bash
# set -eo pipefail

source $HOME/config.nn

case "$1" in

  build)
    # m_notary_build
    pkill -15 iguana
    git pull
    ./$0 build_stage2
  ;;

  build_stage2)
    rm -f ../agents/iguana *.o
    cd secp256k1; ./m_unix; cd ..
    cd ../crypto777; ./m_LP; cd ../iguana
    #gcc -g -fno-aggressive-loop-optimizations -Wno-deprecated -c -O2 -DISNOTARYNODE=1 -DLIQUIDITY_PROVIDER=1 *.c ../basilisk/basilisk.c ../gecko/gecko.c ../datachain/datachain.c
    clang -g -Wno-deprecated -c -O2 -DISNOTARYNODE=1 *.c ../basilisk/basilisk.c ../gecko/gecko.c ../datachain/datachain.c
    #gcc -g -fno-aggressive-loop-optimizations -Wno-deprecated -c -DISNOTARYNODE=1 -DLIQUIDITY_PROVIDER=1  main.c iguana777.c iguana_bundles.c ../basilisk/basilisk.c
    clang -g  -Wno-deprecated -c -DISNOTARYNODE=1 main.c iguana777.c iguana_bundles.c ../basilisk/basilisk.c
    clang -g -o ../agents/iguana *.o ../agents/libcrypto777.a -lnanomsg -lcurl -lssl -lcrypto -lpthread -lz -lm -lsodium
    echo ">>> Done building iguana <<<"
  ;;

  komodo)
    # m_notary
    ./$0 build
    ./$0 kmd
  ;;

  kmd)
    # m_notary_KMD
    $cli_binary lockunspent true `$cli_binary listlockunspent | jq -c .`

    stdbuf -oL $2 ../agents/iguana notary & #> iguana.log 2> error.log  &

    sleep 4
    curl --url "http://127.0.0.1:7776" --data "{\"agent\":\"SuperNET\",\"method\":\"myipaddr\",\"ipaddr\":\"$myip\"}"
    sleep 3

    # TODO: Need to get some seeds for both networks.
    curl --url "http://127.0.0.1:7776" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"2.56.153.50\"}"      # cipi_AR
    curl --url "http://127.0.0.1:7776" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"38.91.101.236\"}"    # cipi_NA
    curl --url "http://127.0.0.1:7776" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"95.213.238.100\"}"
    curl --url "http://127.0.0.1:7776" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"77.75.121.138\"}"
    curl --url "http://127.0.0.1:7776" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"103.6.12.105\"}"
    curl --url "http://127.0.0.1:7776" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"139.99.209.214\"}"
    curl --url "http://127.0.0.1:7776" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"185.130.212.13\"}"
    curl --url "http://127.0.0.1:7776" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"5.9.142.219\"}"
    curl --url "http://127.0.0.1:7776" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"200.25.4.38\"}"
    curl --url "http://127.0.0.1:7776" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"139.99.136.148\"}"
    curl --url "http://127.0.0.1:7776" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"82.202.247.184\"}" # peer2cloud_AR
    curl --url "http://127.0.0.1:7776" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"139.99.144.114\"}" # pungocloud_SH
    curl --url "http://127.0.0.1:7776" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"141.98.206.10\"}" # indenodes_ae
    curl --url "http://127.0.0.1:7776" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"50.97.40.89\"}" # indenodes_sh

    # add KMD
    coins/kmd_7776

    # Unlock
    curl --url "http://127.0.0.1:7776" --data "{\"method\":\"walletpassphrase\",\"params\":[\"$mysecretpassphrase\", 9999999]}"

    # external coins.
    coins/btc_7776

    # Loop through assetchains.json and build the path to the approptiate coins file and run it.
    ./listassetchains | while read chain; do
        coin="coins/$(echo $chain | awk '{print tolower($0)}')_7776"
        $coin
    done

    sleep 20
    # dpow for KMD-> BTC.
    curl --url "http://127.0.0.1:7776" --data "{\"agent\":\"iguana\",\"method\":\"dpow\",\"symbol\":\"KMD\",\"pubkey\":\"$pubkey\"}"

    echo Launching dPoW for ACs
    sleep 20

    # ./dpowassets
    # add non default assetchains here.

    # Loop through assetchains.json and call dpow for them. ROFX will not add a second time.
    ./listassetchains | while read chain; do
        curl --url "http://127.0.0.1:7776" --data "{\"agent\":\"iguana\",\"method\":\"dpow\",\"symbol\":\"$chain\",\"pubkey\":\"$pubkey\"}"
    done
  ;;

  3rdparty)
    # ./m_notary_3rdparty
    ./$0 build

    $cli_binary lockunspent true `$cli_binary listlockunspent | jq -c .`

    # Start 3rd party iguana, no split is default on this branch. This uses RPC port 7779, allows 2 iguana on same OS, incase OP does not have capacity to use 2 VM or 2 servers.
    stdbuf -oL $2 ../agents/iguana 3rd_party & #> iguana.log 2> error.log  &

    sleep 4
    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"SuperNET\",\"method\":\"myipaddr\",\"ipaddr\":\"$myip\"}"
    sleep 3

    # TODO: Need to get some seeds for both networks.

    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"103.6.12.117\"}"
    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"139.99.189.228\"}"
    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"95.213.238.99\"}"
    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"77.75.121.139\"}"
    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"103.6.12.117\"}"
    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"139.162.45.144\"}"
    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"69.64.46.20\"}"      # cipi_NA
    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"152.89.104.58\"}"
    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"5.53.120.34\"}"
    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"139.99.208.141\"}"
    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"141.98.206.10\"}" # indenodes_ae
    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"iguana\",\"method\":\"addnotary\",\"ipaddr\":\"50.97.40.89\"}" # indenodes_sh

    # add KMD
    curl --url "http://127.0.0.1:7779" --data "{\"conf\":\"komodo.conf\",\"path\":\"${HOME#"/"}/.komodo\",\"unitval\":\"20\",\"zcash\":1,\"RELAY\":-1,\"VALIDATE\":0,\"prefetchlag\":-1,\"poll\":10,\"active\":1,\"agent\":\"iguana\",\"method\":\"addcoin\",\"startpend\":8,\"endpend\":8,\"services\":0,\"maxpeers\":32,\"newcoin\":\"KMD\",\"name\":\"Komodo\",\"hasheaders\":1,\"useaddmultisig\":0,\"netmagic\":\"f9eee48d\",\"p2p\":7770,\"rpc\":7771,\"pubval\":60,\"p2shval\":85,\"wifval\":188,\"txfee_satoshis\":\"10000\",\"isPoS\":0,\"minoutput\":10000,\"minconfirms\":2,\"genesishash\":\"027e3758c3a65b12aa1046462b486d0a63bfa1beae327897f56c5cfb7daaae71\",\"protover\":170002,\"genesisblock\":\"0100000000000000000000000000000000000000000000000000000000000000000000003ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4a000000000000000000000000000000000000000000000000000000000000000029ab5f490f0f0f200b00000000000000000000000000000000000000000000000000000000000000fd4005000d5ba7cda5d473947263bf194285317179d2b0d307119c2e7cc4bd8ac456f0774bd52b0cd9249be9d40718b6397a4c7bbd8f2b3272fed2823cd2af4bd1632200ba4bf796727d6347b225f670f292343274cc35099466f5fb5f0cd1c105121b28213d15db2ed7bdba490b4cedc69742a57b7c25af24485e523aadbb77a0144fc76f79ef73bd8530d42b9f3b9bed1c135ad1fe152923fafe98f95f76f1615e64c4abb1137f4c31b218ba2782bc15534788dda2cc08a0ee2987c8b27ff41bd4e31cd5fb5643dfe862c9a02ca9f90c8c51a6671d681d04ad47e4b53b1518d4befafefe8cadfb912f3d03051b1efbf1dfe37b56e93a741d8dfd80d576ca250bee55fab1311fc7b3255977558cdda6f7d6f875306e43a14413facdaed2f46093e0ef1e8f8a963e1632dcbeebd8e49fd16b57d49b08f9762de89157c65233f60c8e38a1f503a48c555f8ec45dedecd574a37601323c27be597b956343107f8bd80f3a925afaf30811df83c402116bb9c1e5231c70fff899a7c82f73c902ba54da53cc459b7bf1113db65cc8f6914d3618560ea69abd13658fa7b6af92d374d6eca9529f8bd565166e4fcbf2a8dfb3c9b69539d4d2ee2e9321b85b331925df195915f2757637c2805e1d4131e1ad9ef9bc1bb1c732d8dba4738716d351ab30c996c8657bab39567ee3b29c6d054b711495c0d52e1cd5d8e55b4f0f0325b97369280755b46a02afd54be4ddd9f77c22272b8bbb17ff5118fedbae2564524e797bd28b5f74f7079d532ccc059807989f94d267f47e724b3f1ecfe00ec9e6541c961080d8891251b84b4480bc292f6a180bea089fef5bbda56e1e41390d7c0e85ba0ef530f7177413481a226465a36ef6afe1e2bca69d2078712b3912bba1a99b1fbff0d355d6ffe726d2bb6fbc103c4ac5756e5bee6e47e17424ebcbf1b63d8cb90ce2e40198b4f4198689daea254307e52a25562f4c1455340f0ffeb10f9d8e914775e37d0edca019fb1b9c6ef81255ed86bc51c5391e0591480f66e2d88c5f4fd7277697968656a9b113ab97f874fdd5f2465e5559533e01ba13ef4a8f7a21d02c30c8ded68e8c54603ab9c8084ef6d9eb4e92c75b078539e2ae786ebab6dab73a09e0aa9ac575bcefb29e930ae656e58bcb513f7e3c17e079dce4f05b5dbc18c2a872b22509740ebe6a3903e00ad1abc55076441862643f93606e3dc35e8d9f2caef3ee6be14d513b2e062b21d0061de3bd56881713a1a5c17f5ace05e1ec09da53f99442df175a49bd154aa96e4949decd52fed79ccf7ccbce32941419c314e374e4a396ac553e17b5340336a1a25c22f9e42a243ba5404450b650acfc826a6e432971ace776e15719515e1634ceb9a4a35061b668c74998d3dfb5827f6238ec015377e6f9c94f38108768cf6e5c8b132e0303fb5a200368f845ad9d46343035a6ff94031df8d8309415bb3f6cd5ede9c135fdabcc030599858d803c0f85be7661c88984d88faa3d26fb0e9aac0056a53f1b5d0baed713c853c4a2726869a0a124a8a5bbc0fc0ef80c8ae4cb53636aa02503b86a1eb9836fcc259823e2692d921d88e1ffc1e6cb2bde43939ceb3f32a611686f539f8f7c9f0bf00381f743607d40960f06d347d1cd8ac8a51969c25e37150efdf7aa4c2037a2fd0516fb444525ab157a0ed0a7412b2fa69b217fe397263153782c0f64351fbdf2678fa0dc8569912dcd8e3ccad38f34f23bbbce14c6a26ac24911b308b82c7e43062d180baeac4ba7153858365c72c63dcf5f6a5b08070b730adb017aeae925b7d0439979e2679f45ed2f25a7edcfd2fb77a8794630285ccb0a071f5cce410b46dbf9750b0354aae8b65574501cc69efb5b6a43444074fee116641bb29da56c2b4a7f456991fc92b2\",\"debug\":0,\"sapling\":1}"

    # unlock wallet
    curl --url "http://127.0.0.1:7779" --data "{\"method\":\"walletpassphrase\",\"params\":[\"$mysecretpassphrase\", 9999999]}"

    # add 3rd party coins to iguana
    coins/chips_7779
    coins/emc2_7779
    coins/mcl_7779
    coins/vrsc_7779
    coins/aya_7779
    coins/gleec_7779
    coins/sfusd_7779

    sleep 30

    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"iguana\",\"method\":\"dpow\",\"symbol\":\"CHIPS\",\"pubkey\":\"$pubkey\"}"
    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"iguana\",\"method\":\"dpow\",\"symbol\":\"EMC2\",\"freq\":5,\"pubkey\":\"$pubkey\"}"
    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"iguana\",\"method\":\"dpow\",\"symbol\":\"MCL\",\"pubkey\":\"$pubkey\"}"
    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"iguana\",\"method\":\"dpow\",\"symbol\":\"VRSC\",\"pubkey\":\"$pubkey\"}"
    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"iguana\",\"method\":\"dpow\",\"symbol\":\"AYA\",\"freq\":5,\"pubkey\":\"$pubkey\"}"
    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"iguana\",\"method\":\"dpow\",\"symbol\":\"GLEEC\",\"pubkey\":\"$pubkey\"}"
    curl --url "http://127.0.0.1:7779" --data "{\"agent\":\"iguana\",\"method\":\"dpow\",\"symbol\":\"SFUSD\",\"pubkey\":\"$pubkey\"}"

  ;;

  *)
    echo "Nothing to see here"
  ;;

esac
