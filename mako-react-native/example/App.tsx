import React, { useEffect } from 'react'
import { Text, View, StyleSheet, Button } from 'react-native'
import { Mako } from 'mako-react-native'

function App(): React.JSX.Element {
  useEffect(() => {
    if (__DEV__) {
      Mako.connect({ host: '192.168.0.3' })
      setTimeout(() => {
        Mako.log('TESTE')
      }, 2000)
    }
  }, [])
  return (
    <View style={styles.container}>
      <Text style={styles.text}></Text>
      <Button title='Teste' onPress={() => {
        Mako.log('TESTE-2')
      }} />
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
