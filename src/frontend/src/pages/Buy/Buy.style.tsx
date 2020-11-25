import styled from 'styled-components/macro'


export const BuyStyled = styled.div`
  margin: 30px;
  position: relative;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-gap: 30px;
`;

export const BuyLandStyled = styled.div`
  position: relative;
  width: 230px;
`;


export const BuyLandBottom = styled.div`
  background-color: #141b43;
  padding: 10px;
  border-radius: 0 0 10px 10px;
`;

export const BuyLandFirstRow = styled.div`
  display: grid;
  grid-template-columns: 50px auto;
  grid-gap: 10px;
`;

export const BuyLandSecondRow = styled.div`
  margin-top: 10px;
`;

export const BuyLandLocation = styled.div`
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

export const BuyLandOnSale = styled.div<{ onSale: boolean }>`
  color: #E50000;
  line-height: 20px;
  text-align: right;
  font-size: 11px;
`;

export const BuyLandButton = styled.button`
  height: 20px;
  font-size: 11px;
  width: 100%;
  background-color: #4c5170;
  box-sizing: border-box;
  border: 0;
  border-radius: 5px;
  color: #FFF;
`;
