import { useState } from "react";
import { secp256k1 } from "@noble/curves/secp256k1";
import { hexToNumber } from "viem";
import { useAccount, useSignTypedData } from "wagmi";
import { Bytes32Input } from "~~/components/scaffold-eth";
import { Contract, ContractName, GenericContract, InheritedFunctions } from "~~/utils/scaffold-eth/contract";

const getVRS = (signatureHex?: string): object | null => {
  if (!signatureHex) return null;
  const { r, s } = secp256k1.Signature.fromCompact(signatureHex.slice(2, 130));
  const v = hexToNumber(`0x${signatureHex.slice(130)}`);
  return { v, r, s };
};

const splitSig = sig => {
  if (!sig) return null;
  // splits the signature to r, s, and v values.
  const pureSig = sig.replace("0x", "");

  const r = new Buffer(pureSig.substring(0, 64), "hex");
  const s = new Buffer(pureSig.substring(64, 128), "hex");
  const v = new Buffer(parseInt(pureSig.substring(128, 130), 16).toString());

  return {
    r,
    s,
    v,
  };
};

// r: 0xecf66027ee8417a28c2d3f7f24d9b22665edb3fc6edcb2f1decef4306e8c3374, s: 0x1fdc7a04625e7a3c6aac54c28f96a06171184875e4511f83b86e30134d08143d, v: 27, sig: undefined

export const SignTypedMessage = ({ deployedContractData }: { deployedContractData: Contract<ContractName> }) => {
  const [message, setMessage] = useState<string>("");
  const res = useSignTypedData();
  const { signTypedData, data } = res;
  console.log("data :", data);
  const account = useAccount();

  const signatureVRS = getVRS(data);
  console.log("signatureVRS :", signatureVRS);
  const permit = splitSig(data);
  if (permit) {
    console.log("permit :", permit);
    console.log(
      `r: 0x${permit.r.toString("hex")}, s: 0x${permit.s.toString("hex")}, v: ${permit.v}, sig: ${permit.signature}`,
    );
  }

  //   const splitSignature = data ? ethers.utils.splitSignature(data) : null;
  //   console.log('splitSignature :', splitSignature);

  return (
    <>
      <div className="flex flex-col gap-3 py-5 first:pt-0 last:pb-1">
        <Bytes32Input
          value={message}
          onChange={setMessage}
          name={"Message to sign"}
          placeholder={"Message to sign"}
          disabled={false}
        />
        {data ? (
          <>
            <p>Owner: 0x8E2f228c0322F872efAF253eF25d7F5A78d5851D</p>
            <p>spender: 0xfC102Ac6cA62f976797b6bF2a423b137649Bf52F</p>
            <p>v: {permit.v}</p>
            <p>r: {`0x${permit.r.toString("hex")}`}</p>
            <p>s: {`0x${permit.s.toString("hex")}`}</p>
          </>
        ) : null}
        <div className="flex justify-between gap-2 flex-wrap">
          <button
            className="btn btn-secondary btn-sm"
            onClick={async () => {
              console.log("clicked");
              signTypedData({
                domain: {
                  name: "MyToken",
                  chainId: 31337,
                  verifyingContract: deployedContractData.address,
                  version: "1",
                },
                types: {
                  Permit: [
                    { name: "owner", type: "address" },
                    { name: "spender", type: "address" },
                    { name: "value", type: "uint256" },
                    { name: "nonce", type: "uint256" },
                    { name: "deadline", type: "uint256" },
                  ],
                },
                primaryType: "Permit",
                message: {
                  owner: account.address,
                  spender: "0xfC102Ac6cA62f976797b6bF2a423b137649Bf52F",
                  value: 1,
                  nonce: 0,
                  deadline: "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
                },
              });
            }}
          >
            Sign Message
          </button>
        </div>
      </div>
    </>
  );
};
