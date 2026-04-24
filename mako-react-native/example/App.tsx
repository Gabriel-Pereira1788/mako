import React, { useEffect } from 'react'
import { Text, View, StyleSheet, Button } from 'react-native'
import { Mako } from 'mako-react-native'

function App(): React.JSX.Element {
  useEffect(() => {
    if (__DEV__) {
      Mako.connect({ host: '192.168.0.2' })
      setTimeout(() => {
        Mako.log('FIRST-LOG')
      }, 2000)
    }
  }, [])
  return (
    <View style={styles.container}>
      <Text style={styles.text}></Text>
      <Button
        title="Test"
        onPress={() => {
          fetch('https://jsonplaceholder.typicode.com/todos/1')
            .then(response => response.json())
            .then(json => Mako.log("RESPONSE-API",json))
        }}
      />
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  text: {
    fontSize: 40,
    color: 'green',
  },
})

export default App
