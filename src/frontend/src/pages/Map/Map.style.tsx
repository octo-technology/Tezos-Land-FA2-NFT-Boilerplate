import styled from "styled-components/macro";

export const MapStyled = styled.div`
  margin: 30px auto;
  width: 500px;
`;

export const MapLandStyled = styled.div`
  position: relative;
  width: 500px;
`;

export const MapLandBottom = styled.div`
  background-color: #141b43;
  padding: 10px;
  border-radius: 0 0 10px 10px;
  margin-bottom: 20px;
`;

export const MapLandFirstRow = styled.div`
  position: relative;
  width: 100%;
  display: grid;
  grid-template-columns: 100px 60px auto;
  grid-gap: 10px;
`;

export const LegendDiv = styled.div`
  color: white;
  line-height: 25px;
  text-align: left;
  font-size: 14px;
`;

export const LegendRow = styled.div`
  position: relative;
  display: grid;
  grid-template-columns: 25px auto;
  grid-gap: 10px;
  margin-top: 8px;
  width: 500px;
`;

export const MapLandLocation = styled.div`
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
    width: 20px;
    height: 20px;
    margin: 3px;
    margin-top: 10px;
    stroke: white;
  }
`;

export const MapLandId = styled.div`
  display: grid;
  grid-template-columns: 1fr 2fr;
  grid-gap: 1px;
  height: 40px;
  width: 60px;
  line-height: 40px;
  border-radius: 5px;
  background-color: #4c5170;

  > svg {
    display: inline-block;
    width: 20px;
    height: 20px;
    margin: 10px 3px 10px 6px;
    stroke: white;
  }

  > div {
    display: inline-block;
    font-size: 14px;
    text-align: center;
    padding-right: 5px;
    line-height: 40px;
    margin-left: 3px;
  }
`;

export const MapLandOwner = styled.div`
  display: grid;
  grid-template-columns: 25px auto;
  grid-gap: 10px;
  height: 40px;
  line-height: 40px;
  border-radius: 5px;
  background-color: #4c5170;
  padding-right: 2px;

  > svg {
    display: inline-block;
    width: 20px;
    height: 20px;
    margin: 10px 3px 10px 6px;
    stroke: white;
  }

  > div {
    display: inline-block;
    font-size: 14px;
    text-align: center;
    padding-right: 5px;
    line-height: 40px;
    margin-left: 3px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
`;

export const MapLandCoordinateInput = styled.input`
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

export const NameTextArea = styled.div`
  margin-top: 10px;
`;

export const DescriptionTextArea = styled.div`
  margin-top: 10px;
`;

export const MapLandButton = styled.button`
  height: 40px;
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
