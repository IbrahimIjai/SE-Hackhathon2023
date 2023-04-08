import Head from "next/head";
import Image from "next/image";
import Link from "next/link";
import heroImage from "../../public/launchpadHeroImage.svg";
import type { NextPage } from "next";

const LandingPage: NextPage = () => {
  return (
    <div className="flex flex-col items-center justify-center">
      <Head>
        <title>LaunchPad App</title>
        <meta name="description" content="Created with 🏗 scaffold-eth" />
      </Head>
      <div className="w-full flex flex-col items-center justify-center gap-6 ">
        <div className="flex items-center flex-col lg:flex-row my-[3rem]">
          <h1 className="w-[40%] text-lg font-bold text-center">
            Get your wonderful web3 ideas to the world Via the worlds biggest community
          </h1>
          <div className="relative w-[30vw] h-[30vh]">
            <Image src={heroImage} fill style={{ objectFit: "contain" }} alt="An image" />
          </div>
        </div>
        <div className="flex flex-col lg:flex-row gap-6">
          {detailsCardArray.map((link, i) => {
            return (
              <div
                key={i}
                className="border border-yellow-400 flex items-start justify-center py-8 px-6 rounded-lg
              flex-col w-[70%] lg:w-[350px] hover:shadow-lg hover:scale-105
              "
              >
                <p className="italic ">Insights</p>
                <p className="text-wrap font-bold text-lg">{link.description}</p>
                <Link href={link.route}>
                  <p>{link.link}</p>
                </Link>
              </div>
            );
          })}
        </div>

        {/* <div> */}
        <h1 className="font-bold text-[3rem]">Upcoming pools</h1>
        <div className="flex w-[80%] flex-wrap gap-8 items-stetch">
          {poolsArray.map((pool, index) => {
            return (
              <Link
                href={`/launchpad/${pool.contract}?projectname=${pool.projectName}&Desc=${pool.briefDesc}`}
                key={index}
                className="flex flex-col items-start px-5 py-3 border w-[70%] lg:w-[250px] border-blue-700 rounded-lg"
              >
                <div className="relative w-[3rem] h-[3rem]">
                  <Image src="/logo.svg" fill style={{ objectFit: "cover" }} alt="project logo" />
                </div>
                <h1>{pool.projectName}</h1>
                <p>{pool.briefDesc}</p>
                <hr className="h-[4px] bg-black" />
                <div>
                  <p></p>
                </div>
              </Link>
            );
          })}
        </div>
        {/* </div> */}
      </div>
    </div>
  );
};

export default LandingPage;

interface GettingStarted {
  title: string;
  description: string;
  link: string;
  route: string;
}

const detailsCardArray: GettingStarted[] = [
  {
    title: "Rules of participation",
    description: "All information regarding cost and value of access to the launchpad",
    link: "Go to docs",
    route: "/",
  },
  {
    title: "Title 2",
    description: "The utility of XXX tokens in the launchpad",
    link: "Go to Docs",
    route: "/",
  },
  {
    title: "Title 2",
    description: "Apply To launch your project ideas",
    link: "Apply",
    route: "/",
  },
];

interface pool {
  projectName: string;
  briefDesc: string;
  targetSales: number;
  type: string;
  contract: string;
}

const poolsArray: pool[] = [
  {
    projectName: "AI GameWorld",
    briefDesc: "A world of gaming, where scenes and environments are all inspired by AI",
    targetSales: 20000,
    type: "Public",
    contract: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 ",
  },
  {
    projectName: "CryptoCollectibles",
    briefDesc: "A platform for collecting and trading unique digital assets on the blockchain",
    targetSales: 5000,
    type: "Private",
    contract: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 ",
  },
  {
    projectName: "Virtual Real Estate",
    briefDesc: "An online marketplace for buying, selling, and developing virtual real estate",
    targetSales: 10000,
    type: "Public",
    contract: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 ",
  },
  {
    projectName: "Decentralized Social Network",
    briefDesc: "A social network where users own their data and control their privacy",
    targetSales: 15000,
    type: "Private",
    contract: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 ",
  },
  {
    projectName: "Blockchain-Based Identity Verification",
    briefDesc: "A solution for secure and decentralized identity verification using blockchain technology",
    targetSales: 7500,
    type: "Public",
    contract: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 ",
  },
];

// type can only either be publick or private
