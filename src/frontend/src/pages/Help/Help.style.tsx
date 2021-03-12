import styled from "styled-components/macro";
import { Page, primaryColor } from "styles";

export const HelpStyled = styled(Page)`
`;

export const HelpPageStyled = styled.div`
  margin: 30px auto;
  width: 1000px;
`;

export const HelpArea = styled.div`
  margin: 5px 10px 20px 10px;
  padding: 10px;
  font-size: 14px;
  background-color: ${primaryColor};
  border-radius: 5px;

  > svg {
    display: inline-block;
    width: 20px;
    height: 20px;
    margin: 3px;
    margin-top: 2px;
    stroke: white;
  }

  > pre { 
    white-space: pre-wrap; 
    font-family: "Proxima Nova";
    font-size: 14px;
  }
`;

export const HelpSectionDiv = styled.div`
  background-color: #141b43;
  padding: 10px;
  border-radius: 10px;
`;

export const HelpQuestionDiv = styled.div`
  background-color: #141b43;
  padding: 10px;
  font-size: 20px;
  border-radius: 0 0 10px 10px;
  font-weight: bold;
`;
