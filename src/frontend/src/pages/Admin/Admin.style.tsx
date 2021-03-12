import styled from "styled-components/macro";

export const AdminStyled = styled.div`
  margin: 30px auto;
  width: 500px;
`;

export const AdminLandStyled = styled.div`
  position: relative;
  width: 500px;
`;

export const AdminLandBottom = styled.div`
  background-color: #141b43;
  padding: 10px;
  border-radius: 0 0 10px 10px;
`;

export const AdminLandFirstRow = styled.div`
  position: relative;
  width: 500px;
`;

export const AdminLandLocation = styled.div`
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

export const AdminLandCoordinateInput = styled.input`
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

export const DescriptionTextArea = styled.textarea`
  margin-top: 10px;
  margin-bottom: 10px;
  font-size: 11px;
  padding: 5px;
  height: 60px;
  width: 100%;
  font-family:"Proxima Nova";
  background-color: #202337;
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


export const AdminLandNameInput = styled.input`
  height: 30px;
  width: 100%;
  margin-top: 10px;
  padding-left: 5px;
  background-color: #202337;
  box-sizing: border-box;
  border: 0;
  border-radius: 5px;
  font-size: 11px;
  font-family:"Proxima Nova"; 

  ::placeholder {
    color: "#727272";
    font-size: 11px;
  }
`;

export const AdminLandDescriptionInput = styled.input`
  height: 60px;
  width: 100%;
  margin-top: 10px;
  margin-bottom: 10px;
  background-color: #202337;
  box-sizing: border-box;
  border: 0;
  border-radius: 5px;
  font-size: 11px;
  text-align: left top;

  ::placeholder {
    color: "#727272";
    font-size: 11px;
  }
`;

export const AdminLandButton = styled.button`
  height: 40px;
  font-size: 11px;
  width: 100%;
  background-color: #4c5170;
  box-sizing: border-box;
  border: 0;
  margin-top: 10px;
  border-radius: 5px;
  color: #fff;
  cursor: pointer;

  > button {
    margin-top: 10px;
  }
`;
