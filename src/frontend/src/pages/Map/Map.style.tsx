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
  width: 500px;
`;

export const MapLandSecondRow = styled.div`
  position: relative;
  margin-top: 8px;
  width: 500px;
`;

export const MapLandThirdRow = styled.div`
  position: relative;
  margin-top: 8px;
  width: 500px;
`;

export const LegendDiv = styled.div`
  color: white;
  line-height: 25px;
  text-align: left;
  font-size: 14px;
`;

export const LegenRow = styled.div`
  position: relative;
  display: grid;
  grid-template-columns: 1fr 8fr;
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
  height: 25px;
  width: 60px;
  line-height: 25px;
  border-radius: 5px;
  background-color: #4c5170;
  margin-top: 10px;

  > svg {
    display: inline-block;
    width: 20px;
    height: 20px;
    margin: 3px;
    margin-top: 2px;
    stroke: white;
  }
  > div {
    display: inline-block;
    font-size: 14px;
    vertical-align: super;
    text-align: right;
    padding-right: 5px;
    line-height: 25px;
    margin-left: 3px;
  }
`;

export const MapLandOwner = styled.div`
  display: grid;
  grid-template-columns: 1fr 8fr;
  grid-gap: 1px;
  height: 25px;
  width: 320px;
  line-height: 25px;
  border-radius: 5px;
  background-color: #4c5170;
  margin-top: 10px;
  padding-right: 2px;
  > svg {
    display: inline-block;
    width: 20px;
    height: 20px;
    margin: 3px;
    margin-top: 2px;
    stroke: white;
  }
  > div {
    display: inline-block;
    font-size: 14px;
    vertical-align: super;
    text-align: left;
    padding-right: 5px;
    line-height: 25px;
    margin-left: 3px;
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

export const NameTextArea = styled.textarea`
  margin-top:20px;
  padding-left: 5px;
  padding-top: 2px;
  font-size: 13px;
  height: 20px;
  width: 100%;
  cursor: default;
  background-color: #141b43;
  border-radius: 5px;
  border: none;
  resize: none;
  color: white;
  ::placeholder {
    color: "#727272";
    font-size: 11px;
  }
`;

export const DescriptionTextArea = styled.textarea`
  margin-top: 2px;
  font-size: 11px;
  padding: 5px;
  height: 60px;
  width: 100%;
  cursor: default;
  background-color: #141b43;
  border-radius: 5px;
  border: none;
  overflow-y: auto;
  resize: none;
  color: white;
  ::placeholder {
    color: "#727272";
    font-size: 11px;
  }
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
