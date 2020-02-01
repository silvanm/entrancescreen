import Vue from 'vue';
import VueRouter from 'vue-router';
import Snapshots from '../views/Snapshots';
import Persons from '../views/Persons';
import Login from '../views/Login';
import Flutter from '../views/Flutter';
import firebase from 'firebase';

Vue.use(VueRouter);

const routes = [
  {
    path: '*',
    redirect: '/login'
  },
  {
    path: '/',
    redirect: '/login'
  },
  {
    path: '/home',
    name: 'home',
    component: Snapshots,
    meta: {
      requiresAuth: true
    }
  },
  {
    path: '/persons',
    name: 'persons',
    component: Persons,
    meta: {
      requiresAuth: true
    }
  },
  {
    path: '/login',
    name: 'login',
    component: Login
  },
  {
    path: '/flutter',
    name: 'flutter',
    component: Flutter,
  },
];

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
});

router.beforeEach((to, from, next) => {
  const currentUser = firebase.auth().currentUser;
  const requiresAuth = to.matched.some(record => record.meta.requiresAuth);

  if (requiresAuth && !currentUser) next('login');
  else next();
});

export default router;
