import styled from "styled-components/macro";

export const SellStyled = styled.div`
  margin: 30px;
  position: relative;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-gap: 30px;
`;

export const SellLandStyled = styled.div`
  position: relative;
  width: 230px;
`;

export const SellTokenGrid = styled.div`
  display: grid;
  grid-template-columns: 2fr 3fr;
  grid-gap: 10px;
  width: 240px;
  position: relative;
  margin: auto;
  z-index: 2;
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
  }

  > div {
    display: inline-block;
    font-size: 11px;
    vertical-align: super;
    line-height: 17px;
    margin-left: 3px;
  }
`;

export const SellLandOnSale = styled.div<{ onSale: boolean }>`
  color: ${(props) => (props.onSale ? "#E50000" : "#FFF")};
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
`;

