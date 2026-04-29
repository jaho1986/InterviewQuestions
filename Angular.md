# Angular Interview Concepts

---

## 1. Components
The basic building block of Angular apps. A component controls a portion of the UI.

```typescript
@Component({
  selector: 'app-hello',
  template: `<h1>Hello, {{ name }}!</h1>`,
})
export class HelloComponent {
  name = 'World';
}
```

---

## 2. Modules (`NgModule`)
Containers that group related components, directives, pipes, and services.

```typescript
@NgModule({
  declarations: [AppComponent],
  imports: [BrowserModule],
  bootstrap: [AppComponent],
})
export class AppModule {}
```

> In Angular 14+, **Standalone Components** can be used without NgModules.

---

## 3. Data Binding
The mechanism that synchronizes data between the component class and its template. There are four types depending on the direction of the data flow.

| Type | Syntax | Direction |
|---|---|---|
| Interpolation | `{{ value }}` | Component → View |
| Property Binding | `[src]="url"` | Component → View |
| Event Binding | `(click)="fn()"` | View → Component |
| Two-Way Binding | `[(ngModel)]="value"` | Both |

---

## 4. Directives
Instructions that tell Angular how to transform the DOM. There are three types: components (directives with a template), structural (change the DOM layout), and attribute (change the appearance or behavior of an element).

- **Structural** – modify the DOM structure.
- **Attribute** – modify element appearance or behavior.

```html
<!-- Structural -->
<div *ngIf="isVisible">Visible</div>
<li *ngFor="let item of items">{{ item }}</li>

<!-- Attribute -->
<p [ngClass]="{ active: isActive }">Text</p>
```

---

## 5. Services & Dependency Injection (DI)
Services hold business logic and are injected into components via DI.

```typescript
@Injectable({ providedIn: 'root' })
export class DataService {
  getData() { return ['a', 'b', 'c']; }
}

// In a component:
constructor(private dataService: DataService) {}
```

---

## 6. Lifecycle Hooks
Methods that Angular calls at specific points in a component's life.

| Hook | When it fires |
|---|---|
| `ngOnInit` | After first render |
| `ngOnChanges` | When input properties change |
| `ngOnDestroy` | Before component is destroyed |
| `ngAfterViewInit` | After the view is initialized |

```typescript
export class MyComponent implements OnInit, OnDestroy {
  ngOnInit() { console.log('initialized'); }
  ngOnDestroy() { console.log('destroyed'); }
}
```

---

## 7. Input & Output
Decorators used to share data between parent and child components. `@Input()` passes data down to the child; `@Output()` emits events up to the parent.

```typescript
// Child component
@Input() title: string = '';
@Output() clicked = new EventEmitter<string>();

sendEvent() {
  this.clicked.emit('Hello from child');
}
```

```html
<!-- Parent template -->
<app-child [title]="'Hello'" (clicked)="onClicked($event)" />
```

---

## 8. Pipes
Transform data in templates.

```html
<!-- Built-in pipes -->
{{ price | currency:'USD' }}
{{ today | date:'shortDate' }}
{{ name | uppercase }}
```

```typescript
// Custom pipe
@Pipe({ name: 'reverse' })
export class ReversePipe implements PipeTransform {
  transform(value: string): string {
    return value.split('').reverse().join('');
  }
}
```

---

## 9. Routing
Angular's built-in navigation system that maps URL paths to components. Configured via a `Routes` array and rendered with `<router-outlet>`.

```typescript
const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'about', component: AboutComponent },
  { path: '**', redirectTo: '' },
];
```

```html
<a routerLink="/about">About</a>
<router-outlet />
```

---

## 10. Route Guards
Control access to routes.

```typescript
@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanActivate {
  canActivate(): boolean {
    return !!localStorage.getItem('token');
  }
}

// In routes:
{ path: 'dashboard', component: DashboardComponent, canActivate: [AuthGuard] }
```

---

## 11. Lazy Loading
Load feature modules only when needed to improve performance.

```typescript
const routes: Routes = [
  {
    path: 'admin',
    loadChildren: () =>
      import('./admin/admin.module').then(m => m.AdminModule),
  },
];
```

---

## 12. Reactive Forms
A model-driven approach to handling form inputs. The form structure is defined explicitly in the component class using `FormGroup` and `FormControl`, giving full control over validation and state.

```typescript
form = new FormGroup({
  name: new FormControl('', Validators.required),
  email: new FormControl('', [Validators.required, Validators.email]),
});

onSubmit() {
  console.log(this.form.value);
}
```

```html
<form [formGroup]="form" (ngSubmit)="onSubmit()">
  <input formControlName="name" />
  <input formControlName="email" />
  <button type="submit">Submit</button>
</form>
```

---

## 13. Template-Driven Forms
Simpler approach using directives in the template.

```html
<form #myForm="ngForm" (ngSubmit)="onSubmit(myForm)">
  <input name="username" ngModel required />
  <button type="submit">Submit</button>
</form>
```

---

## 14. HttpClient
Used to make HTTP requests.

```typescript
@Injectable({ providedIn: 'root' })
export class ApiService {
  constructor(private http: HttpClient) {}

  getUsers() {
    return this.http.get<User[]>('https://api.example.com/users');
  }
}
```

---

## 15. Interceptors
Intercept and modify HTTP requests/responses globally.

```typescript
@Injectable()
export class AuthInterceptor implements HttpInterceptor {
  intercept(req: HttpRequest<any>, next: HttpHandler) {
    const cloned = req.clone({
      setHeaders: { Authorization: `Bearer ${token}` },
    });
    return next.handle(cloned);
  }
}
```

---

## 16. RxJS & Observables
Angular relies heavily on RxJS for async operations.

```typescript
import { of, interval } from 'rxjs';
import { map, filter, take } from 'rxjs/operators';

interval(1000).pipe(
  take(5),
  filter(n => n % 2 === 0),
  map(n => n * 10),
).subscribe(console.log); // 0, 20, 40
```

---

## 17. Subject vs BehaviorSubject
Both are multicast Observables that allow values to be pushed to multiple subscribers. The key difference is that `BehaviorSubject` requires an initial value and always replays the last emitted value to new subscribers.

| | `Subject` | `BehaviorSubject` |
|---|---|---|
| Initial value | ❌ No | ✅ Yes |
| Late subscribers get last value | ❌ No | ✅ Yes |

```typescript
const bs = new BehaviorSubject<number>(0);
bs.next(1);
bs.subscribe(v => console.log(v)); // Immediately logs: 1
```

---

## 18. Change Detection
Angular checks for UI changes using two strategies:

- **Default** – checks the whole component tree.
- **OnPush** – only checks when inputs change or an event fires (better performance).

```typescript
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class OptimizedComponent {}
```

---

## 19. ViewChild & ContentChild
Decorators that give the component class direct access to DOM elements or child components. `@ViewChild` targets elements in the component's own template; `@ContentChild` targets elements projected via `<ng-content>`.

```typescript
@ViewChild('myInput') inputRef!: ElementRef;

ngAfterViewInit() {
  this.inputRef.nativeElement.focus();
}
```

```html
<input #myInput type="text" />
```

---

## 20. Standalone Components (Angular 14+)
Components that don't need an NgModule.

```typescript
@Component({
  standalone: true,
  selector: 'app-root',
  imports: [CommonModule, RouterModule],
  template: `<h1>Standalone!</h1>`,
})
export class AppComponent {}
```

---

## 21. Signals (Angular 16+)
A new reactive primitive for fine-grained reactivity.

```typescript
import { signal, computed, effect } from '@angular/core';

count = signal(0);
double = computed(() => this.count() * 2);

increment() {
  this.count.update(v => v + 1);
}
```

---

## 22. `trackBy` in `*ngFor`
Improves rendering performance by tracking items by a unique key.

```html
<li *ngFor="let user of users; trackBy: trackById">{{ user.name }}</li>
```

```typescript
trackById(index: number, user: User) {
  return user.id;
}
```

---

## 23. Pure vs Impure Pipes
Defines when Angular re-executes a pipe's `transform` method. Pure pipes are more performant and should be the default; impure pipes should be used sparingly as they can hurt performance.

- **Pure** (default): only re-runs when the input reference changes.
- **Impure**: re-runs on every change detection cycle (use carefully).

```typescript
@Pipe({ name: 'myPipe', pure: false })
export class ImpurePipe implements PipeTransform { ... }
```

---

## 24. AOT vs JIT Compilation
Two ways Angular compiles HTML templates and TypeScript into JavaScript. **AOT** (Ahead-of-Time) compiles at build time, resulting in smaller bundles and faster startup. **JIT** (Just-in-Time) compiles in the browser at runtime, useful during development.

| | AOT | JIT |
|---|---|---|
| Compiled | Build time | Runtime |
| Performance | Faster | Slower |
| Default in prod | ✅ Yes | ❌ No |

---

## 25. Angular Universal (SSR)
Renders Angular apps on the server for better SEO and initial load performance.

```bash
ng add @angular/ssr
```

The app is rendered on the server and sent as static HTML to the browser.
