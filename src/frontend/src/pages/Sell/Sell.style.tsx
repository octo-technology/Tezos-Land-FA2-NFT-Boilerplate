import styled from "styled-components/macro";

export const SellStyled = styled.div`
  margin: 30px auto;
  width: 500px;
`;

export const SellLandStyled = styled.div`
  position: relative;
  width: 500px;
`;

export const SellLandBottom = styled.div`
  background-color: #141b43;
  padding: 10px;
  border-radius: 0 0 10px 10px;
`;

export const SellLandFirstRow = styled.div`
  position: relative;
  width: 500px;
`;

export const SellLandSecondRow = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr;
  grid-gap: 10px;
  margin-top: 10px;
`;

export const SellLandLocation = styled.div`
  display: grid;
  grid-template-columns: 1fr 2fr 2fr;
  grid-gap: 1px;
  height: 40px;
  width: 100px;
  line-height: 20px;
  border-radius: 5px;
  background-color: #4c5170;

  > svg {
    display: inline-block;
    width: 24px;
    height: 24px;
    margin: 4px;
    margin-top: 6px;
  }
`;

export const SellLandCoordinateInput = styled.input`
  height: 25px;
  text-align: center;
  width: 75%;
  margin-top: 8px;
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

export const SellLandPriceInput = styled.input`
  height: 30px;
  width: 100%;
  margin-top: 5px;
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
  height: 30px;
  font-size: 11px;
  width: 100%;
  background-color: #4c5170;
  box-sizing: border-box;
  border: 0;
  margin-top: 5px;
  border-radius: 5px;
  color: #fff;
  cursor: pointer;
`;

export const CancelSaleButton = styled.button`
  height: 30px;
  font-size: 11px;
  width: 100%;
  background-color: #4c5170;
  box-sizing: border-box;
  border: 0;
  margin-top: 5px;
  border-radius: 5px;
  color: #FFF;
  margin-left: 3px;
  cursor: pointer;
`;