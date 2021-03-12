import styled from "styled-components/macro";

export const HelpPageStyled = styled.div`
  margin: 30px auto;
  width: 1000px;
`;

export const HelpTempleTextArea = styled.textarea`
  margin: 5px auto 30px auto;
  padding: 5px;
  font-size: 14px;
  width: 100%;
  font-family:"Proxima Nova";
  font-size: 15px;
  height:160px;
  cursor: hidden;
  background-color: #4c5170;
  border-radius: 5px;
  border: none;
  resize: none;
  color: white;
`;

export const HelpTutorialTextArea = styled.textarea`
  margin: 5px auto 30px auto;
  padding: 5px;
  font-size: 14px;
  width: 100%;
  height:50px;
  font-family:"Proxima Nova";
  cursor: default;
  background-color: #4c5170;
  border-radius: 5px;
  font-size: 15px;
  border: none;
  resize: none;
  color: white;
`;

export const HelpSectionStyled = styled.div`
  position: relative;
  width: 1000px;
`;


export const HelpSectionDiv = styled.div`
  background-color: #141b43;
  padding: 10px;
  border-radius: 0 0 10px 10px;
`;

export const HelpQuestionDiv = styled.div`
  background-color: #141b43;
  padding: 10px;
  font-size: 20px;
  border-radius: 0 0 10px 10px;
  font-weight: bold;
`;


export const HelpAnswerDiv = styled.div`
  display: grid;
  grid-template-columns: 1fr 30fr;
  grid-gap: 1px;
  font-size: 15px;
  height: 25px;
  width: 100%;
  line-height: 25px;
  border-radius: 5px;
  background-color: #4c5170;
  margin-top: 10px;
  margin-bottom: 30px;
  padding-right: 10px;

  > svg {
    display: inline-block;
    width: 20px;
    height: 20px;
    margin: 3px;
    margin-top: 2px;
    stroke: white;
  }
`;