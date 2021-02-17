const NaCl = require('tweetnacl');

hex_bytes = process.argv[2]
private_key = process.argv[3]
address = process.argv[4]
console.log("hex_bytes=" + hex_bytes)
console.log("private_key=" + private_key)
console.log("address=" + address)

const key_pair = NaCl.sign.keyPair.fromSecretKey(Buffer.from(private_key, "hex"))
const secret_key = key_pair.secretKey;
console.log("secret_key=" + secret_key)

signed_hex_bytes = Buffer.from(
        NaCl.sign.detached(
          Buffer.from(hex_bytes, "hex"),
          secret_key
        )
      ).toString("hex")

console.log(signed_hex_bytes)
