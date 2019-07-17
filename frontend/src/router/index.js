import Vue from 'vue'
import Router from 'vue-router'
import HelloWorld from '@/components/HelloWorld'
import DBTest from '@/components/DBTest'
import Home from '@/components/Home'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'Home',
      component: Home
    },
    { path: '/hello',
      name: 'HelloWorld',
      component: HelloWorld
    },
    { path: '/dbtest',
      name: 'DBTest',
      component: DBTest
    }
  ]
})
