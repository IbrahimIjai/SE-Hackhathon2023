import { useState } from "react";
import Head from "next/head";
import Image from "next/image";
import { useRouter } from "next/router";
import type { NextPage } from "next";
import { useContract, useProvider } from "wagmi";
import { useContractWrite, useNetwork, useWaitForTransaction } from "wagmi";
import { ContractUI } from "~~/components/scaffold-eth";


const PoolInfo: NextPage = () => {
  const provider = useProvider();
  const [purchaseAmount, setPurchasedAmount] = useState("");
  const [purchasing, setPurchasing] = useState(false);
  const router = useRouter();
  const { projectname, Desc, pool } = router.query;

  const handleInputChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setPurchasedAmount(event.target.value);
  };

  //purchase token function

//   const contract = useContract({
//     address: deployedContractData?.address,
//     abi: deployedContractData?.abi as Abi,
//     signerOrProvider: provider,
//   });

  return (
    <div className=" w-screen pt-[10vh] flex flex-col items-center">
      <Head>
        <title>Buy Page</title>
        <meta name="description" content="Created with 🏗 scaffold-eth" />
      </Head>

      <div className="flex flex-col lg:flex-row items-start justify-center gap-6">
        <div className="relative w-[5rem] h-[5rem]">
          <Image src="/logo.svg" fill style={{ objectFit: "cover" }} alt="project logo" />
        </div>
        <div>
          <h1 className="font-bold text-[2.5rem]">{projectname}</h1>
          <p className="text-[1.4rem] font-semibold text-wrap lg:w-[450px]">{Desc}</p>
        </div>
      </div>

      <div>
        <h1 className="font-bold text-[2.5rem]">Stats</h1>
        <div>
          <p>Total Raised:</p>
          <p></p>
        </div>
        <div>
          <p>Total tokensold:</p>
          <p>
            {0}/{1000000}
          </p>
        </div>
      </div>

      <div>
        <h1 className="font-bold text-[2.5rem]">Participate</h1>
        <p>Enter the amount you wish to purchase</p>
        <input
          className="border border-blue-400 focus:outline-none px-3 py-2 w-[250px]"
          type="text"
          value={purchaseAmount}
          onChange={handleInputChange}
        />
        <button
          className="border border-blue-400 bg-blue-400 text-white px-3 py-2 ml-4 disabled:opacity-50"
          disabled={purchasing}
        //   onClick={handlePurchase}
        >
          {purchasing ? "Purchasing..." : "Purchase"}
        </button>
      </div>
      <ContractUI/>
    </div>
  );
};

export default PoolInfo;
