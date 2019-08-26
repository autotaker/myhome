<template>
  <div class="auth">
    <form>
      <div>
        <label>Username: <input v-model="username" type="text" name="username"></label>
      </div>
      <div>
        <label>Password: <input v-model="password" type="password" name="password"></label>
      </div>
      <button v-on:click="submit" type="button">{{ authType }}</button>
    </form>
  </div>
</template>

<script>
import auth from '@/api/auth.js'
export default {
  name: 'Auth',
  props: ['authType'],
  data() {
    return {
      username: '',
      password: '',
    };
  },
  methods: {
    submit() {
      if( this.authType === 'signin' ) {
        auth.signin(this.username, this.password);
      }else {
        auth.signup(this.username, this.password);
      }
    }
  }
}
</script>

<style scoped>
.auth {
  width: 300px;
  height: 300px;
}
</style>


