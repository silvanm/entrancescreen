import Vue from 'vue'
import VueRouter from 'vue-router'
import Snapshots from '../views/Snapshots';
import Persons from '../views/Persons';

Vue.use(VueRouter);

const routes = [
  {
    path: '/',
    name: 'home',
    component: Snapshots
  },
  {
    path: '/persons',
    name: 'persons',
    component: Persons,
  }
];

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

export default router
