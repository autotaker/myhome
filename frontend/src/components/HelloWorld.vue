<template>
  <div class="hello">
    <h1>{{ msg }}</h1>
  </div>
</template>

<script>
import hello from '@/api/hello.js'
export default {
  name: 'HelloWorld',
  data () {
    return {
      msg: 'Waiting for the response from API Server...'
    }
  },
  watch: {
    msg: {
      handler() {
        hello.hello().then(data => {
          this.msg = 'Message sent from API Server:' + data.message
        }).catch(error => console.error('Error:', error))
      },
      immediate: true
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h1, h2 {
  font-weight: normal;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
