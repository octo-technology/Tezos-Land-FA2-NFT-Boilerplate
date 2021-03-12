// prettier-ignore
import { TEZOSLAND_ADDRESS } from "dapp/defaults";
import * as React from "react";
import { Message, Page } from "styles";

import { HelpView } from "./Help.view";


type HelpProp = {

};
export const Help = ({ }: HelpProp) => {
    return (
        <Page>
            <HelpView contractAddress={TEZOSLAND_ADDRESS} />
        </Page>
    );
};
