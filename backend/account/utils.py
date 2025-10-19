from typing import Optional
from django.contrib.auth.models import AnonymousUser
from account.models import Userian

def resolve_userian_from_request(request, fallback_user_id: int | None = None) -> Optional[Userian]:
    """
    Try to infer the Userian row from:
      1) request.user.email
      2) the "cust_<id>" username pattern
      3) explicit fallback_user_id (e.g., from request.data or query string)
    Returns Userian or None.
    """
    user = getattr(request, "user", None)

    # 1) Try by email if we have an authenticated user with email
    if user and not isinstance(user, AnonymousUser):
        email = getattr(user, "email", "") or ""
        if email:
            cust = Userian.objects.filter(email=email).first()
            if cust:
                return cust

        # 2) Try the "cust_<id>" convention
        username = getattr(user, "username", "") or ""
        if username.startswith("cust_"):
            try:
                cid = int(username.split("_", 1)[1])
                cust = Userian.objects.filter(id=cid).first()
                if cust:
                    return cust
            except Exception:
                pass

    # 3) Fallback to explicit id
    if fallback_user_id:
        return Userian.objects.filter(id=fallback_user_id).first()

    return None