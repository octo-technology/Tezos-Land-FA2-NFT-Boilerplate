import styled from "styled-components/macro";

export const LandMapStyled = styled.div<{ isAdmin: boolean }>`
  height: ${(props) => (props.isAdmin ? "500px" : "230px")};
  width: ${(props) => (props.isAdmin ? "500px" : "230px")};
  display: grid;
  grid-template-columns: repeat(10, 1fr);

  > :nth-child(1) {
    border-radius: 10px 0 0 0;
  }

  > :nth-child(10) {
    border-radius: 0 10px 0 0;
  }
`;

export const LandMapTile = styled.div<{ selected: boolean; isAdmin: boolean; exists: boolean }>`
  height: ${(props) => (props.isAdmin ? "50px" : "23px")};
  width: ${(props) => (props.isAdmin ? "50px" : "23px")};
  border: ${(props) => (props.selected ? "1px solid #FFFFFF" : "1px solid #141b43 ")};
  background-color: ${(props) => (props.exists ? "#E50000" : "#202337")};
`;
