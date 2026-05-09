import { Routes } from '@angular/router';
import { LoginComponent } from './features/auth/login/login.component';

export const routes: Routes = [
  { path: '', redirectTo: 'login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  // Rutas futuras (pendientes de implementación con backend)
  // { path: 'dashboard', component: DashboardComponent, canActivate: [AuthGuard] },
  // { path: 'usuarios',  component: UsuariosComponent,  canActivate: [AuthGuard] },
  // { path: 'votaciones',component: VotacionesComponent,canActivate: [AuthGuard] },
  // { path: 'mesas',     component: MesasComponent,     canActivate: [AuthGuard] },
  // { path: 'resultados',component: ResultadosComponent, canActivate: [AuthGuard] },
  { path: '**', redirectTo: 'login' },
];
