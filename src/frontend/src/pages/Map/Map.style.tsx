import styled from "styled-components/macro";

export const MapStyled = styled.div`
  margin: 30px;
  position: relative;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-gap: 30px;
`;

export const MapLandStyled = styled.div`
  position: relative;
  width: 230px;
`;

export const MapLandBottom = styled.div`
  background-color: #141b43;
  padding: 10px;
  border-radius: 0 0 10px 10px;
`;

export const MapLandFirstRow = styled.div`
  display: grid;
  grid-template-columns: 50px auto;
  grid-gap: 10px;
`;

export const MapLandSecondRow = styled.div`
  position: relative;
  width: 230px;
`;

export const MapLandThirdRow = styled.div`
  position: relative;
  width: 230px;
`;

export const MapLandLocation = styled.div`
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

export const MapLandOnSale = styled.div<{ onSale: boolean }>`
  color: ${(props) => (props.onSale ? "#E50000" : "#FFF")};
  line-height: 20px;
  text-align: right;
  font-size: 11px;
`;
export const MapLandName = styled.div`
  color: #FFF;
  line-height: 20px;
  text-align: left;
  font-weight: bold;
  font-size: 13px;
`;
export const MapLandDescription = styled.div`
  color: #FFF;
  line-height: 20px;
  text-align: left;
  font-size: 11px;
  margin-right: 7px;
`;
