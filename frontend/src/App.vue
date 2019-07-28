<template>
  <div id="app">
    <nav>
      <ul>
        <router-link tag="li" to="/" exact> <a><strong>MyHome</strong></a></router-link>
        <router-link tag="li" to="/hello" exact> <a>Hello</a></router-link>
        <router-link tag="li" to="/dbtest" exact> <a>DBTest</a></router-link>
      </ul>
    </nav>
    <router-view/>
  </div>
</template>

<script>

export default {
  name: 'app',
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}
nav {
  background-color: #4fc08d;
}
nav ul {
  display: flex;
  list-style: none;
  align-items: center;
  justify-content: left;
  height: 40px;
}
nav ul li {
  padding-right: 10px;
}
nav ul li a {
  color: #fff;
  text-decoration: none;
}
</style>
