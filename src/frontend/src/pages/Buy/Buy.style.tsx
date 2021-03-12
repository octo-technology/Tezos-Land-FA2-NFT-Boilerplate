import styled from 'styled-components/macro'
import { GridPage } from 'styles';

export const BuyStyled = styled(GridPage)`
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
  grid-template-columns: 50px 50px auto;
  grid-gap: 10px;
`;

export const BuyLandSecondRow = styled.div`
  position: relative;
  margin-top: 10px;
`;

export const BuyLandThirdRow = styled.div`
  position: relative;
  margin-top: 10px;
`;

export const BuyLandFourthRow = styled.div`
  margin-top: 10px;
`;

export const BuyLandData = styled.div<{ isOnSale?: boolean }>`
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