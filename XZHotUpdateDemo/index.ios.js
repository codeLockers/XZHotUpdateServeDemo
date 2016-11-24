/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  Image
} from 'react-native';

export default class XZHotUpdateDemo extends Component {
  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Hot Update Version 0.3!
        </Text>
      <Image
      style={{width:100,height:300}}
      source={require('./img/test.png')}/>
      <Image
      style={{width:100,height:100}}
      source={require('./img/logo.png')}/>
      </View>
    );
  }
}

       

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

AppRegistry.registerComponent('XZHotUpdateDemo', () => XZHotUpdateDemo);
