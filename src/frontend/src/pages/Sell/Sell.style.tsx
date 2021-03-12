import styled from "styled-components/macro";
import { GridPage } from "styles";

export const SellStyled = styled(GridPage)``;

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
  grid-template-columns: 50px 50px auto;
  grid-gap: 10px;
`;

export const SellLandSecondRow = styled.div`
  position: relative;
  margin-top: 10px;
`;

export const SellLandThirdRow = styled.div`
  position: relative;
  margin-top: 10px;
`;

export const SellLandFourthRow = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr;
  grid-gap: 10px;
  margin-top: 10px;
`;

export const SellLandData = styled.div<{ isOnSale?: boolean }>`
  height: 25px;
  line-height: 25px;
  border-radius: 5px;
  background-color: #4c5170;
  color: ${(props) => (props.isOnSale ? "#E50000" : "#FFF")};
  display: grid;
  grid-template-columns: 25px auto;

  > svg {
    display: inline-block;
    width: 15px;
    height: 15px;
    margin: 5px;
    stroke: white;
  }

  > div {
    text-align: center;
    display: inline-block;
    font-size: 11px;
    line-height: 25px;
    vertical-align: top;
    margin-left: 0px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
`;

export const SellLandPriceInput = styled.input`
  height: 25px;
  width: 100%;
  background-color: #202337;
  box-sizing: border-box;
  border: 0;
  border-radius: 5px;
  font-size: 11px;
  line-height: 25px;
  padding-left: 10px;

  ::placeholder {
    color: "#727272";
    font-size: 11px;
    margin-left: 10px;
  }
`;

export const SellLandButton = styled.button`
  height: 20px;
  font-size: 11px;
  line-height: 20px;
  line-height: 20px;
  width: 100%;
  background-color: #4c5170;
  box-sizing: border-box;
  border: 0;
  border-radius: 5px;
  color: #fff;
  cursor: pointer;
`;

export const CancelSaleButton = styled.button`
  height: 20px;
  font-size: 11px;
  line-height: 20px;
  background-color: #4c5170;
  box-sizing: border-box;
  border: 0;
  border-radius: 5px;
  color: #fff;
  margin-left: 3px;
  cursor: pointer;
`;
