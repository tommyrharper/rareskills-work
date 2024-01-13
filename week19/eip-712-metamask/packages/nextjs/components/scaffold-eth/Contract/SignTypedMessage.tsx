import { useEffect, useState } from "react";
import { useAccount, useBlockNumber, usePublicClient, useSignTypedData } from "wagmi";
import { Bytes32Input, IntegerInput } from "~~/components/scaffold-eth";
import { Contract, ContractName } from "~~/utils/scaffold-eth/contract";

const splitSig = (sig?: string) => {
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

const ONE_DAY = 86400;

export const SignTypedMessage = ({ deployedContractData }: { deployedContractData: Contract<ContractName> }) => {
  const [owner, setOwner] = useState<string>("");
  const [spender, setSpender] = useState<string>("");
  const [value, setValue] = useState<bigint | string>("");
  const [nonce, setNonce] = useState<bigint | string>("");

  const [block, setBlock] = useState();
  console.log("block :", block?.timestamp);
  const [deadline, setDeadline] = useState<bigint | string>(block?.timestamp);
  const publicClient = usePublicClient();

  useEffect(() => {
    publicClient
      .getBlock() // https://viem.sh/docs/actions/public/getBlock.html
      .then(x => setBlock(x))
      .then(x => setDeadline(x?.timestamp ? x?.timestamp + ONE_DAY : 1000))
      .catch(error => console.log(error));
  }, [publicClient]);

  const { signTypedData, data } = useSignTypedData();
  const account = useAccount();
  const permit = splitSig(data);

  return (
    <>
      <div className="flex flex-col gap-3 py-5 first:pt-0 last:pb-1">
        <p>You account: {account.address}</p>
        <Bytes32Input value={owner} onChange={setOwner} name={"Owner"} placeholder={"Owner"} disabled={false} />
        <Bytes32Input value={spender} onChange={setSpender} name={"Spender"} placeholder={"Spender"} disabled={false} />
        <IntegerInput value={value} onChange={setValue} name={"Value"} placeholder={"Value"} disabled={false} />
        <IntegerInput value={nonce} onChange={setNonce} name={"Nonce"} placeholder={"Nonce"} disabled={false} />
        <IntegerInput
          value={deadline}
          onChange={setDeadline}
          name={"Deadline"}
          placeholder={"Deadline"}
          disabled={false}
        />
        {permit ? (
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
                  owner,
                  spender,
                  value,
                  nonce,
                  deadline,
                },
              });
            }}
          >
            Sign ERC20 Permit
          </button>
        </div>
      </div>
    </>
  );
};
