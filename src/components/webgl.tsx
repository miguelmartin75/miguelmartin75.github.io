/** @jsx jsx */

import * as React from 'react';
import { jsx } from "theme-ui"
import styled from "styled-components";

const StyledCanvas = styled.canvas`
pointer-events: none;
`;


class WebGl extends React.Component {
  constructor(props) {
    super(props);
    this.state = { }
  }

  componentDidMount() {
    this.props.func();
  }

  render() {
    return <StyledCanvas id="glCanvas" height="100vh" sx={{position: 'absolute', top: 0, left: 0}}></StyledCanvas>
  }
}

export default WebGl;
