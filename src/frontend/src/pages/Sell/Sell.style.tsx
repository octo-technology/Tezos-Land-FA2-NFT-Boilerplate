import styled from "styled-components/macro";
import { GridPage } from "styles";

export const SellStyled = styled(GridPage)`
`;

export const SellLandStyled = styled.div`
  position: relative;
  width: 230px;
  margin: auto;
`;

export const SellLandBottom = styled.div`
  background-color: #141b43;
  padding: 10px;
  border-radius: 0 0 10px 10px;
`;

export const SellLandFirstRow = styled.div`
  display: grid;
  grid-template-columns: 50px auto;
  grid-gap: 10px;
`;

export const SellLandSecondRow = styled.div`
  position: relative;
  margin-top: 8px;
  width: 500px;
`;

export const SellLandThirdRow = styled.div`
  position: relative;
  margin-top: 8px;
  width: 500px;
`;

export const SellLandFourthRow = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr;
  grid-gap: 10px;
  margin-top: 10px;
`;

export const SellLandLocation = styled.div`
  height: 20px;
  width: 50px;
  line-height: 20px;
  border-radius: 5px;
  background-color: #4c5170;
  > svg {
    display: inline-block;
    width: 12px;
    height: 12px;
    margin: 4px;
    stroke: white;
  }
  > div {
    display: inline-block;
    font-size: 11px;
    vertical-align: super;
    line-height: 17px;
    margin-left: 3px;
  }
`;

export const SellLandOwner = styled.div`
display: grid;
  grid-template-columns: 20px auto;
  height: 20px;
  width: 210px;
  line-height: 20px;
  border-radius: 5px;
  background-color: #4c5170;
  > svg {
    display: inline-block;
    width: 12px;
    height: 12px;
    margin: 4px;
    stroke: white;
  }
  > div {
    display: inline-block;
    font-size: 9px;
    vertical-align: super;
    line-height: 20px;
    margin-left: 3px;
  }
`;

export const SellLandId = styled.div`
display: grid;
  grid-template-columns: 20px auto;
  height: 20px;
  width: 40px;
  line-height: 20px;
  border-radius: 5px;
  background-color: #4c5170;
  > svg {
    display: inline-block;
    width: 12px;
    height: 12px;
    margin: 4px;
    stroke: white;
  }
  > div {
    display: inline-block;
    font-size: 9px;
    vertical-align: super;
    text-align: right;
    padding-right: 5px;
    line-height: 20px;
    margin-left: 3px;
  }
`;



export const SellLandOnSale = styled.div<{ isOnSale: boolean }>`
  color: ${(props) => (props.isOnSale ? "#E50000" : "#FFF")};
  line-height: 20px;
  text-align: right;
  font-size: 11px;
`;

export const SellLandPriceInput = styled.input`
  height: 20px;
  width: 100%;
  background-color: #202337;
  box-sizing: border-box;
  border: 0;
  border-radius: 5px;
  font-size: 11px;
  ::placeholder {
    color: "#727272";
    font-size: 11px;
  }
`;

export const SellLandButton = styled.button`
  height: 20px;
  font-size: 11px;
  width: 100%;
  background-color: #4c5170;
  box-sizing: border-box;
  border: 0;
  border-radius: 5px;
  color: #FFF;
  cursor: pointer;
`;

export const CancelSaleButton = styled.button`
  height: 20px;
  font-size: 11px;
  width: 200%;
  background-color: #4c5170;
  box-sizing: border-box;
  border: 0;
  border-radius: 5px;
  color: #FFF;
  margin-left: 3px;
  cursor: pointer;
`;