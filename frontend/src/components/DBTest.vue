<template>
  <div class="dbtest">
    <h1 class="dbtest-header">Results</h1>
    <div class="dbtest-content">
      <ul>
        <li v-for="(item,index) in items" :key="index">
          {{ index }}: {{ item.message }}
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import hello from '@/api/hello.js'
export default {
  name: 'DBTest',
  data: () => {
    return {
      items: []
    }
  },
  created () {
    this.fetchData()
  },
  watch: {
    '$route': 'fetchData'
  },
  methods: {
    fetchData () {
      hello.dbtest().then(data => {
        this.items = data
      })
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h1, h2 {
  font-weight: normal;
}
.dbtest{
  border: solid;
  border-color: #000000;
  display: block;
  margin-left: 60px;
  margin-right: 60px;
}
.dbtest-content{
  display: flex;
  align-content: center;
}

ul {
  list-style-type: none;
  width: 100px;
  padding: 0;
  border: solid;
  margin: 10px 10px 10px 10px;
  border-color: #000000;
}
li {
  display: block;
  text-align: left;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
