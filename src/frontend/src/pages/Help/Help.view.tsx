// prettier-ignore
import { HelpArea, HelpPageStyled, HelpQuestionDiv, HelpSectionDiv, HelpStyled } from "./Help.style";

type HelpViewProps = {
  contractAddress: string;
};

export const HelpView = ({ contractAddress }: HelpViewProps) => {
  return (
    <HelpPageStyled>
      <Help contractAddress={contractAddress} />
    </HelpPageStyled>
  );
};

const Help = ({ contractAddress }: HelpViewProps) => {
  return (
    <HelpStyled>
      <HelpSectionDiv>
        <HelpQuestionDiv>What is the TezosLand ?</HelpQuestionDiv>
        <HelpArea>
          TezosLand is a free and open-source boilerplate for developers to fork
          and modify to create your own NFT marketplace on Tezos. You can find
          the Github repo{" "}
          <a
            href="https://github.com/octo-technology/Tezos-Land-FA2-NFT-Boilerplate"
            target="_blank"
            rel="noreferrer"
          >
            <u>here</u>
          </a>{" "}
          and more info about how to get started on{" "}
          <a href="https://OpenTezos.com" target="_blank" rel="noreferrer">
            <u>OpenTezos.com</u>
          </a>
          . Notice that TezosLand.io is just a demo running on the Delphi
          Testnet for you to play.
        </HelpArea>
        <HelpQuestionDiv>
          Where is the TezosLand demo smart contract deployed at?
        </HelpQuestionDiv>
        <HelpArea>{`${contractAddress}`}</HelpArea>
        <HelpQuestionDiv>
          How to add a token into the Temple wallet?
        </HelpQuestionDiv>
        <HelpArea>
          <pre>{`1) Open the Temple wallet extension.\n
2) In the "Assets" section, click on "Manage".\n
3) Click "Add Token".\n
4) Select FA2, and copy-paste the contract address: ${contractAddress}\n
5) Enter the token ID of the land you want to import. You can find the ID of all your tokens on the 'Sell' page.\n
6) Temple will try to load the token metadata from https://tezosland.io/metadata/contract_metadata.json\n
7) Click on "Add Token".\n
8) Your token should now appear in your list of assets.
`}</pre>
        </HelpArea>
        <HelpQuestionDiv>Any question? Need help?</HelpQuestionDiv>
        <HelpArea>
          Contact us on the{" "}
          <a
            href="https://github.com/octo-technology/Tezos-Land-FA2-NFT-Boilerplate"
            target="_blank"
            rel="noreferrer"
          >
            <u>Github issues</u>
          </a>
          .
        </HelpArea>
      </HelpSectionDiv>
    </HelpStyled>
  );
};
