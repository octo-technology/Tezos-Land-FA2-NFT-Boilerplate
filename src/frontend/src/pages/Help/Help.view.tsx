import * as React from "react";
import { useAlert } from 'react-alert'

// prettier-ignore
import {
  HelpPageStyled,
  HelpSectionDiv,
  HelpSectionStyled,
  HelpAnswerDiv,
  HelpQuestionDiv,
  HelpTempleTextArea,
  HelpTutorialTextArea
} from "./Help.style";



type HelpViewProps = {
  contractAddress: string
};

export const HelpView = ({ contractAddress
}: HelpViewProps) => {
  return (
    <HelpPageStyled>
      <Help contractAddress={contractAddress} />
    </HelpPageStyled>
  );
};

const Help = ({ contractAddress }: HelpViewProps) => {
  const alert = useAlert()

  return (
    <HelpSectionStyled>
      <HelpSectionDiv>
        <HelpQuestionDiv>
          What is the contract address ?
        </HelpQuestionDiv>
        <HelpAnswerDiv>
          <svg>
            <use xlinkHref="/icons/sprites.svg#barcode" />
          </svg>
          <div>{`${contractAddress}`}</div>
        </HelpAnswerDiv>
        <HelpQuestionDiv>
          How to add a token into Temple Wallet ?
        </HelpQuestionDiv>
        <HelpTempleTextArea readOnly>
          {"1) Open the Temple Wallet extension. \n\
2) In the Assets section, click on 'Manage'.\n\
3) Select then Add Token.\n\
4) Select FA2, and copy-paste the contract address: " + contractAddress + "\n\
5) Choose the land that you want to import into Temple. You can find the id of all your lands in the 'Sell' page.\n\
6) Temple will try to load the token metadata from https://tezosland.io/metadata/contract_metadata.json\n\
7) You can change them if you want to. Click on Add Token.\n\
8) Your token is now available in Temple."}
        </HelpTempleTextArea>
        <HelpQuestionDiv>
          Where can I find some tutorials about TezosLand ?
        </HelpQuestionDiv>
        <HelpTutorialTextArea readOnly>
          {"Three articles will soon be available, explaining how to set up your own marketplace. You will find references to these articles as soon as they are published."}
        </HelpTutorialTextArea>

      </HelpSectionDiv>


    </HelpSectionStyled>

  );
};