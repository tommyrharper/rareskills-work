
from ecpy.curves import Curve
from ecpy.keys import ECPublicKey, ECPrivateKey
from sha3 import keccak_256

# used an online random number generator to generate a 256-bit number, then went and randomly flipped ~25 bits manually for extra security
result = b'1011110101010111110100100011011100010111011001110010100011010100111110100101110010110101101110101011100010111001000010100101011110110001101111000011001111010011011110000111110000000101100101000011011110000100010111001101100110001111110110111011010110110011'
private_key = int(result, 2)
cv = Curve.get_curve('secp256k1')

def get_eth_addr(pk):
    pv_key = ECPrivateKey(pk, cv)
    pu_key = pv_key.get_public_key()

    # equivalent alternative for illustration:
    # concat_x_y = bytes.fromhex(hex(pu_key.W.x)[2:] + hex(pu_key.W.y)[2:])

    concat_x_y = pu_key.W.x.to_bytes(32, byteorder='big') + pu_key.W.y.to_bytes(32, byteorder='big')
    eth_addr = '0x' + keccak_256(concat_x_y).digest()[-20:].hex()
    return eth_addr

eth_addr = get_eth_addr(private_key)

for i in range(2_000_000):
    eth_addr = get_eth_addr(private_key)
    if eth_addr[:6] == '0x0000':
        break
    private_key += 1

print('private key: ', hex(private_key))
print('eth_address: ', eth_addr)
