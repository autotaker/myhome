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
    submit: async function() {
      if( this.authType === 'signin' ) {
        try {
          await auth.signin(this.username, this.password);
          this.$emit('signined', this.username);
        } catch(err) {
          this.$notify({
            group: 'main',
            type: 'error',
            title: 'Signin Failed',
            text: err.message
          });
        }        
      }else {
        try {
          await auth.signup(this.username, this.password);
          console.log(this.username);
          this.$emit('signuped', this.username);
        } catch(err) {
          this.$notify({
            group: 'main',
            type: 'error',
            title: 'Signup Failed',
            text: err.message
          });
        }
        
      }
    }
  }
}
</script>

<style scoped>
.auth {
  width: 300px;
  background-color: #cccccc
}
</style>


